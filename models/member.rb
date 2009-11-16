require 'bcrypt'

class Member 

  include CouchPlastic
  
  # =========================================================
  #                     CONSTANTS
  # =========================================================  

  class IncorrectPassword < StandardError; end
  class InvalidPermissionLevel < StandardError
    def initialize(obj)
      super( obj.inspect )
    end
  end
 
  SECURITY_LEVELS = [ :NO_ACCESS, :STRANGER, :MEMBER, :EDITOR, :ADMIN ]
  SECURITY_LEVELS.each do |k|
    const_set k, k
  end
  
  EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/
  LIVES = [
      :friend,
      :family,
      :work,
      :romance,
      :pet_owner,
      :celebrity
  ]

  #VALID_USERNAME_FORMAT = /\A[a-zA-Z0-9\-\_\.]{2,25}\z/
  #VALID_USERNAME_FORMAT_IN_WORDS = "letters, numbers, underscores, dashes and periods."


  # =========================================================
  #                     GET Methods (Class)
  # =========================================================    
  
  def self.by_username username
    raise ArgumentError, "Invalid username: #{username.inspect}" if !username
    CouchDoc.GET(:member_usernames, :key=>username, :limit=>1, :include_docs=>true)
  end


  # =========================================================
  #                     CRUD Methods.
  # =========================================================

  enable_timestamps

  during(:create) {
    demand :add_life, :password
    ask_for :avatar_link, :email
  }

  during(:update) { 

    from(:self) {
      ask_for(:password, :old_life, :add_life) 
    }

    from(ADMIN) {
      ask_for(:permission_level, :old_life, :add_life)
    }

  }


  # =========================================================
  #           Authorization Methods (Class + Instance)
  # =========================================================

  def creator? editor # NEW, CREATE
    return true if !editor
    false
  end

  def reader? editor # SHOW
    true
  end

  def updator? editor # EDIT, UPDATE
    return false if !editor
    return true if self._id == editor._id
    return true if editor.has_power_of?(:ADMIN)
    false
  end

  def deletor? editor # DELETE
    updator? editor
  end


  # Based on Sinatra-authentication (on github).
  # 
  # Parameters:
  #   raw_vals - Hash with at least 2 keys: :username, :password
  # 
  # Raises: 
  #   Member::IncorrectPassword
  #
  def self.authenticate( raw_vals )
      
      un = Member.by_username( raw_vals[:username] )

      correct_password = BCrypt::Password.new(un.owner.hashed_password) === (raw_vals[:password] + un.owner.salt)
      
      if correct_password
        return un.owner
      end

      raise IncorrectPassword, "Password is invalid for: #{raw_vals[:username]}"

  end # === self.authenticate

  # =========================================================
  #                     ACCESSORS (Instance)
  # =========================================================

  def usernames
    assoc_cache[:usernames] ||= lives.map { |l| l[:username]}
  end

  # 
  # By using a custom implementation, we cane make sure
  # sensitive information is not shown.
  #
  def inspect
    assoc_cache[:inspect_string] ||= "#<#{self.class} id=#{self.original[:_id]}>"
  end
  
  def has_power_of?(raw_level)

    return true if raw_level == self
    
    target_level = raw_level.is_a?(String) ? raw_level.to_sym : raw_level

    if !SECURITY_LEVELS.include?(target_level)
      raise InvalidPermissionLevel.new(raw_level)
    end
    
    return false if target_level == NO_ACCESS
    return true if target_level == STRANGER
    return false if new? 

    member_index = SECURITY_LEVELS.index(self.permission_level)
    target_index = SECURITY_LEVELS.index(target_level)
    return member_level_index >= target_index

  end # === def security_clearance?

  # 
  # Returns the time passed to it to the Member's local time
  # as a String, formatted i18n to their Country preference.
  # Default value of :utc is Time.now.utc
  # 
  def local_time_as_string( utc = nil )
    utc ||= Time.now.utc
    @tz_proxy ||= TZInfo::Timezone.get(self.timezone)
    @tz_proxy.utc_to_local( utc ).strftime('%a, %b %d, %Y @ %I:%M %p')
  end # ===   
  
  # =========================================================
  #                 SETTERS (Instance)
  # =========================================================

  setter :password, :confirm_password do |pass, confirm_pass|
   
    stringify_and_strip
    
    select_error {

      must_match_string(confirm_pass) {
        "Password and password confirmation do not match."
      }
      
      check_size( 5 )

      must_match(/[0-9]/) {
        "Password must have at least one number."
      }

    }

    custom_set {

      set(:salt) {
        # Salt and encrypt values.
        chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
        (1..10).inject('') { |new_pass, i|  
          new_pass += chars[rand(chars.size-1)] 
          new_pass
        }
      }

      set(:hashed_password) {
        BCrypt::Password.create( pass + self.new_values[:salt] ).to_s
      }

    }

  end # === def set_password
  
  
  setter :permission_level do |val|
    must_be_in(SECURITY_LEVELS) { |val|
      raise InvalidPermissionLevel.new(val)
    }
  end # === def set_permission_level
  
 
  setter :email do |val|

    valid_email_chars   = /\A[a-zA-Z0-9\.\-\_\+\@]{8,}\z/
    email_finder        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
    valid_email_format  = /\A#{email_finder}\z/

    default_error_msg = 'Email is invalid.'

    select_error {
      must_be_string
      check_size(6)
      must_match_original_after_cleaning(/[^a-z0-9\.\-\_\+\@]/i) 

    }
  
  end # === def email=
  
  def check *col 
    val = raw_data[col]
    val = val.strip if val.is_a?(String)
    if_no_errors {
      set_value
    }
  end

  setter :add_life do
    
    check(:add_life) { |val|
      must_be_in(LIVES) 
    }
    
    check(:add_life_username) {
      # Delete invalid characters and 
      # reduce any suspicious characters. 
      # '..*' becomes '.', '--' becomes '-'
      clean_with(/[^a-z0-9]{1,}/i) { |s|
        if ['_', '.', '-'].include?( s[0,1] )
          s[0,1]
        else
          ''
        end
      }

      check_size( 2, 20 )

      # Check to see if there is at least one alphanumeric character
      if_no_errors {
        must_have( /[a-z0-9]/i , 'Username must have at least one letter or number.' ) 
      }

      custom_setter {
        new_data[:lives]
      }
    }


  end # === def validate_new_values
  
  
  setter :history do
    @history_msgs = []
    
    raise "Fix this code below."

    raw_vals.each { |k,v|
      case k.to_sym
        when :username
          history_msgs << "Changed username from: #{self[:username]}"
        when :email
          history_msgs << "Changed email from: #{self[:email]}"
      end
    }
    return true if !@history_msgs.empty?
    
    HistoryLog.create_it!( 
     :owner_id  => self.owner[:id], 
     :editor_id => self.current_editor[:id], 
     :action    => 'UPDATE', 
     :body      => @history_msgs.join("\n")
    )  

    doc.save_update
  end # === def history=





end # === model Member

  
  
