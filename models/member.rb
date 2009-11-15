require 'bcrypt'

class Member 

  include CouchPlastic
  
  # =========================================================
  #                     CONSTANTS
  # =========================================================  

  class IncorrectPassword < StandardError; end
  class InvalidPermissionLevel < StandardError; end
 
  SECURITY_LEVELS = [ :NO_ACCESS, :STRANGER, :MEMBER, :EDITOR, :ADMIN ]
  SECURITY_LEVELS.each do |k|
    const_set k, k
  end
  
  EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/
  LIFE_CATEGORIES = {
    1 => 'Friend',
    2 => 'Family',
    3 => 'Work',
    4 => 'Romance',
    5 => 'Pet Owner',
    6 => 'Celebrity',
    7 => 'Role Playing'
  }   

  LIFE_CATEGORY_IDS = LIFE_CATEGORIES.keys.sort

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
    demand :new_life, :password
    ask_for :avatar_link, :email
  }

  during(:update) { 

    from(:self) {
      ask_for(:password) 
    }

    from(ADMIN) {
      ask_for(:permission_level)
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
  #                     SETTERS/ACCESSORS (Instance)
  # =========================================================

  def usernames
    assoc_cache[:usernames] ||= Username.get_by_owner( self.original[:_id] )
  end


  # By using a custom implementation, we cane make sure
  # sensitive information is not shown.
  def inspect
    assoc_cache[:inspect_string] ||= "#<#{self.class} id=#{self.original[:_id]}>"
  end
  
  
  def has_power_of?(raw_level)

    return true if raw_level == self
    
    target_level = raw_level.is_a?(String) ? raw_level.to_sym : raw_level

    if !SECURITY_LEVELS.include?(target_level)
      raise InvalidPermissionLevel, "#{raw_level.inspect} is not a valid permission level."
    end
    
    return false if target_level == NO_ACCESS
    return true if target_level == STRANGER
    return false if new? 

    member_index = SECURITY_LEVELS.index(self.permission_level)
    target_index = SECURITY_LEVELS.index(target_level)
    return member_level_index >= target_index

  end # === def security_clearance?

  
  def password=(raw_data)
    pass         = raw_data[:password ].to_s.strip
    confirm_pass = raw_data[:confirm_password].to_s.strip
    
    if pass != confirm_pass 
      self.errors << "Password and password confirmation do not match." 
    
    elsif pass.empty?
      self.errors <<  "Password is required."
    
    elsif pass.length < 5
      self.errors << "Password must be longer than 5 characters."    
    
    elsif !pass[/[0-9]/]
      self.errors << "Password must have at least one number."
    end

    return nil if !self.errors.empty?
    
    # Salt and encrypt values.
    self.new_values[:salt] =  begin
                                chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
                                (1..10).inject('') { |new_pass, i|  
                                  new_pass += chars[rand(chars.size-1)] 
                                  new_pass
                                }
                              end
    
    self.new_values[:hashed_password] = BCrypt::Password.create( pass + self.new_values[:salt] ).to_s
    confirm_pass
      
  end # === def set_password
  
  
  def permission_level= raw_data

    fn = :permission_level
  
    new_level = raw_data[fn]
    
    if !SECURITY_LEVELS.include?(new_level.to_sym)
      raise InvalidPermissionLevel, "#{new_level} is not a valid permission level."  
    end
    
    self.new_values[fn] = new_level
    
  end # === def set_permission_level
  
 

  # =========================================================
  # Returns the time passed to it to the Member's local time
  # as a String, formatted i18n to their Country preference.
  # Default value of :utc is Time.now.utc
  # =========================================================
  def local_time_as_string( utc = nil )
    utc ||= Time.now.utc
    @tz_proxy ||= TZInfo::Timezone.get(self.timezone)
    @tz_proxy.utc_to_local( utc ).strftime('%a, %b %d, %Y @ %I:%M %p')
  end # ===   

  def email= raw_params
    valid_email_chars   = /\A[a-zA-Z0-9\.\-\_\+\@]{8,}\z/
    email_finder        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
    valid_email_format  = /\A#{email_finder}\z/

    o = raw_params[ :email ] 
    v = v.to_s.gsub( /[^a-z0-9\.\-\_\+\@]/i , '')

    if v != o || v !~ valid_email_format 
      self.errors << "Email is invalid." 
    elsif v.length < 6
      self.errors << "Email is too short." 
    end
  
    if self.errors.empty?
      self.new_values[:email] = v  
      return self.new_values[:email]
    end

    v
  end # === def email=
  
  
  def new_life= raw_data
    fn = :username
    raw_name = raw_data[fn].to_s.strip
    
    # Delete invalid characters and 
    # reduce any suspicious characters. 
    # '..*' becomes '.', '--' becomes '-'
    new_un = raw_name.gsub( /[^a-z0-9]{1,}/i  ) { |s| 
      if ['_', '.', '-'].include?( s[0,1] )
        s[0,1]
      else
        ''
      end
    }          
    
    # Check to see if there is at least one alphanumeric character
    if new_un.empty?
      self.errors << 'Username is required.'
    elsif new_un.length < 2
      self.errors << 'Username is too short. (Must be 3 or more characters.)' 
    elsif new_un.length > 20
      self.errors << 'Username is too long. (Must be 20 characters or less.)' 
    elsif !new_un[ /[a-z0-9]/i ] && self.errors.empty?
      self.errors << 'Username must have at least one letter or number.' 
    end
    
    if self.errors.empty?
      self.new_values[fn] = new_un
      self.new_values[:_id] = "username-#{new_un}"
      return new_un
    end

    nil
  end # === def validate_new_values
  
  
  def history= raw_data
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

  
  
