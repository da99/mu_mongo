require 'bcrypt'

class Member 

  include CouchPlastic

  enable_timestamps
  
  allow_fields :created_at, 
             :updated_at, 
             :lives, 
             :data_model, 
             :hashed_password, 
             :salt,
             :security_level

  # =========================================================
  #                     CONSTANTS
  # =========================================================  
  
  IncorrectPassword      = Class.new( StandardError )
  InvalidPermissionLevel = Class.new( StandardError )

  SECURITY_LEVELS        = [ :NO_ACCESS, :STRANGER, :MEMBER, :EDITOR, :ADMIN ]
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

  # ==== Class Methods =====================================================    

  def self.valid_security_level?(perm_level)
    SECURITY_LEVELS.include?(perm_level)
  end

  # ==== Getters =====================================================    
  
  def self.new_from_db *args
    doc = super(*args)

    sec_level = doc.original_data.security_level
    if sec_level
      doc.original_data.security_level = sec_level.to_sym
    end

    doc
  end

  def self.by_username raw_username
    username = demand_string_not_empty(raw_username)
    CouchDoc.GET( :member_usernames, 
                  :key=>username, 
                  :limit=>1, 
                  :include_docs=>true
    )
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
      username = demand_string_not_empty raw_vals[:username]
      password = demand_string_not_empty raw_vals[:password]
      mem      = Member.by_username( username )

      correct_password = BCrypt::Password.new(mem.original_data.hashed_password) === (password + mem.data.salt)
      
      return mem if correct_password

      raise IncorrectPassword, "Password is invalid for: #{username.inspect}"
  end 

  # ==== CRUD/CRUD-related =====================================================

  def setter_for_create
		new_data._id = CouchDoc.GET_uuid
    new_data.ask_for :avatar_link, :email
    new_data.demand  :password, :add_life
  end
    
  
  def setter_for_update 

    new_data.ask_for :old_life, :add_life 

    if manipulator == self
      new_data.ask_for :password  
    end

    if manipulator.has_power_of? ADMIN
      new_data.ask_for :security_level
    end

  end

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
    return true if self.data._id == editor.data._id
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
    assoc_cache[:inspect_string] ||= "#<#{self.class} id=#{self.data._id}>"
  end
  
  def usernames
    assoc_cache[:usernames] ||= original_data.lives.values.map { |l| l[:username]}
  end

  def security_level
    return :MEMBER if !original_data.as_hash.has_key?(:security_level) && !new?
    original_data.as_hash[:security_level]
  end

  def any_of_these_powers?(*raw_levels)
    raw_levels.flatten.detect { |level| 
      has_power_of?(level) 
    }
  end

  def has_power_of?(raw_level)

    return true if raw_level == self
    
    target_level = raw_level.is_a?(String) ? raw_level.to_sym : raw_level

    if !SECURITY_LEVELS.include?(target_level)
      raise InvalidPermissionLevel, raw_level.inspect
    end
    
    return false if target_level == NO_ACCESS
    return true if target_level == STRANGER
    return false if new? 

    member_index = SECURITY_LEVELS.index(self.security_level)
    target_index = SECURITY_LEVELS.index(target_level)
    return member_index >= target_index

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

  def password_validator
                
    confirm_password = raw_data[:confirm_password].to_s.strip

    password = clean(:password) {
      strip
      must_equal confirm_password, 'Password and password confirmation do not match.'
      min_size   5
      match( /[0-9]/, 'Password must have at least one number' )
    }
    
    new_data.salt = begin
                        # Salt and encrypt values.
                        chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
                        (1..10).inject('') { |new_pass, i|  
                          new_pass += chars[rand(chars.size-1)] 
                          new_pass
                        }
                      end

    new_data.hashed_password = BCrypt::Password.create( password + new_data.salt ).to_s
    
  end
  
  def security_level_validator 
    new_data.security_level = clean(:security_level) {
      if_not_in(SECURITY_LEVELS) { 
        raise Member::InvalidPermissionLevel, security_level.inspect
      }
    }
  end # === def set_security_level
  
 
  def email_validator  

    valid_email_chars   = /\A[a-zA-Z0-9\.\-\_\+\@]{8,}\z/
    email_finder        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
    valid_email_format  = /\A#{email_finder}\z/

    new_data.email = clean(:email) {
      
      error_msg 'Email is invalid.'
      
      must_be_string
      min_size 6
      clean_with(  /[^a-z0-9\.\-\_\+\@]/i  )
      match_with original_value
      
    }
  
  end # === def email=
  
  def add_life_validator 
    
    add_life = clean(:add_life) { symbolize }
    
    demand_array_includes Member::LIVES, add_life
      
    if !new?
      demand_array_not_include lives.keys, add_life
    end

    new_data.lives ||= {}
    new_data.lives[add_life]={}
    
    add_life_username_validator

  end # ======== validator :add_life
  
  def add_life_username_validator

    add_life_username = clean(:add_life_username) do 
      
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

      between_size 2, 20,  'Username must be between %d and %d characters.'
      match( /[a-z0-9]/i,  'Username must have at least one letter or number.') 

    end 

    new_data.lives[clean_data[:add_life]][:username] = add_life_username
    
    if errors.empty?
      begin
        _reserve_username_( add_life_username )
      rescue CouchDoc::HTTP_Error_409_Update_Conflict
        errors << "Username already taken: #{add_life_username}"
      end
    end
			

  end # validator :add_life_username

	def _reserve_username_ new_un
		this_id = if new?
								if new_data._id
									new_data._id
								else
									new_data._id = CouchDoc.GET_uuid
								end
							else
								_id
							end
		doc_id = 'username-' + new_un
		CouchDoc.PUT( doc_id,  {:member_id=>this_id} )
	end

  private # ==================================================

  def _add_to_history_(hash)
    if !hash.is_a?(Hash)
      raise ArgumentError, "Only Hash object is allowed."
    end

    hash[:timestamp] = self.class.utc_now 

    self.new_data.history ||= self.history
    self.history << hash
  end

end # === model Member




