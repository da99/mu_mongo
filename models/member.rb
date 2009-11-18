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


  # ==== Getters =====================================================    
  
  def self.by_username username
    raise ArgumentError, "Invalid username: #{username.inspect}" if !username
    CouchDoc.GET(:member_usernames, :key=>username, :limit=>1, :include_docs=>true)
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

  end 

  # ==== CRUD/CRUD-related =====================================================

  enable_timestamps

  during(:create) { 
    demand :add_life, :password
    ask_for :avatar_link, :email
  }

  during(:update) { 

    ask_for :old_life, :add_life 

    from(:self) {
      ask_for :password  
    }

    from(ADMIN) {
      ask_for :permission_level
    }

  }

  # ==== Authorizations =====================================================

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


  # ==== ACCESSORS =====================================================

  # 
  # By using a custom implementation, we cane make sure
  # sensitive information is not shown.
  #
  def inspect
    assoc_cache[:inspect_string] ||= "#<#{self.class} id=#{self.original[:_id]}>"
  end
  
  def usernames
    assoc_cache[:usernames] ||= lives.map { |l| l[:username]}
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
  end 
  
  # ==== Validators =====================================================

  validator :password, :confirm_password do 
   
    strip
    
    detect {

      match(confirm_password) {
        "Password and password confirmation do not match."
      }
      
      min_size( 5 )

      match(/[0-9]/) {
        "Password must have at least one number."
      }

    }

    override {

      set_other(:salt) {
        # Salt and encrypt values.
        chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
        (1..10).inject('') { |new_pass, i|  
          new_pass += chars[rand(chars.size-1)] 
          new_pass
        }
      }

      set_other(:hashed_password) {
        BCrypt::Password.create( pass + self.new_values[:salt] ).to_s
      }

    }

  end # === def set_password
  
  
  validator :permission_level do 
    if_not_in(SECURITY_LEVELS) { 
      raise InvalidPermissionLevel.new(permission_level)
    }
  end # === def set_permission_level
  
 
  validator :email do 

    valid_email_chars   = /\A[a-zA-Z0-9\.\-\_\+\@]{8,}\z/
    email_finder        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
    valid_email_format  = /\A#{email_finder}\z/

    default_error_msg 'Email is invalid.'

    select_error {
      must_be_string
      min_size(6)
      match_original_after_cleaning(/[^a-z0-9\.\-\_\+\@]/i) 
    }
  
  end # === def email=
  
  validator :add_life do 

    symbolize
    
    if_in(doc.lives.keys) {
      raise %~
        Either programmer error or 
        security attempt: 
        No existing life allowed in 
        :add_life from user data.
      ~.split.join(' ')
    }

    if_not_in(LIVES) { 
      raise %~
        Error or Security Attempt: 
        Invalid Life category: 
        #{add_life.inspect}
      ~.split.join(' ')
    }
    
    
    validator(:add_life_username) {

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

      between_size( 2, 20 )

      select_error {
        match( /[a-z0-9]/i ) {
          'Username must have at least one letter or number.' 
        }
      }

      override {
        doc.new_data[:lives][add_life][:username] = add_life_username
      }

    } # validator :add_life_username

  end # validator :add_life
  
  def _add_to_history_(hash)
    if !hash.is_a?(Hash)
      raise ArgumentError, "Only Hash object is allowed."
    end

    hash[:timestamp] = self.class.utc_now 

    self.new_data[:history] ||= self.history
    self.history << hash
  end

end # === model Member

