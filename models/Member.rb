require 'bcrypt'

class Member 

  include Couch_Plastic

  enable_timestamps
  
  allow_fields :lives, 
               :data_model, 
               :hashed_password, 
               :salt,
               :security_level

  # =========================================================
  #                     CONSTANTS
  # =========================================================  
  
  Incorrect_Password      = Class.new( StandardError )
  Invalid_Security_Level = Class.new( StandardError )

  SECURITY_LEVELS        = %w{ NO_ACCESS STRANGER  MEMBER  EDITOR   ADMIN }
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
  ].map(&:to_s).freeze

  #VALID_USERNAME_FORMAT = /\A[a-zA-Z0-9\-\_\.]{2,25}\z/
  #VALID_USERNAME_FORMAT_IN_WORDS = "letters, numbers, underscores, dashes and periods."

  # ==== Class Methods =====================================================    

  def self.valid_security_level?(perm_level)
    SECURITY_LEVELS.include?(perm_level)
  end

  # ==== Getters =====================================================    
  
  def self.by_username raw_username
    username = demand_string_not_empty(raw_username)
    Couch_Doc.GET( :member_usernames, 
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
  #   Member::Incorrect_Password
  #
  def self.authenticate( raw_vals )
      username = demand_string_not_empty raw_vals[:username]
      password = demand_string_not_empty raw_vals[:password]
      mem      = Member.by_username( username )

      correct_password = BCrypt::Password.new(mem.original_data.hashed_password) === (password + mem.data.salt)
      
      return mem if correct_password

      raise Incorrect_Password, "Password is invalid for: #{username.inspect}"
  end 

  # ==== Hooks =====================================================

  def before_create
		new_data._id            = Couch_Doc.GET_uuid
		new_data.security_level = Member::MEMBER
    ask_for :avatar_link, :email
    demand  :password, :add_life
  end
    
  
  def before_update 

    ask_for :old_life, :add_life 

    if manipulator == self
      ask_for :password  
    end

    if manipulator.has_power_of? ADMIN
      ask_for :security_level
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

  def has_power_of?(raw_level)

    return true if raw_level == self
    
    target_level = raw_level.is_a?(String) ? raw_level.to_sym : raw_level

    if !SECURITY_LEVELS.include?(target_level)
      raise Invalid_Security_Level, raw_level.inspect
    end
    
    return false if target_level == NO_ACCESS
    return true if target_level == STRANGER
    return false if new? 

    member_index = SECURITY_LEVELS.index(self.data.security_level)
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
    sanitize { strip }

    must_be {
      equal doc.raw_data[:confirm_password], 'Password and password confirmation do not match.'
      min_size 5
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

    new_data.hashed_password = BCrypt::Password.create( cleanest_value(:password) + new_data.salt ).to_s
    
  end
  
  def security_level_validator 
    must_be_or_raise! { 
      in_array Security_Levels 
    }
  end # === def set_security_level
  
 
  def email_validator  

    valid_email_chars   = /\A[a-zA-Z0-9\.\-\_\+\@]{8,}\z/
    email_finder        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
    valid_email_format  = /\A#{email_finder}\z/

    sanitize {
      with(  /[^a-z0-9\.\-\_\+\@]/i  )
    }

    must_be {
      
      string
      min_size 6
      equal raw_data[:email], 'Email has invalid characters.'
      
    }
  
  end # === def email=
  
  def add_life_validator 
    
    must_be_or_raise! {
      in_array Member::LIVES
    }
      
    if !new?
      must_be_or_raise! {
        not_in_array doc.data.lives.keys
      }
    end

    new_data.lives = (original_data.lives || {})
    new_data.lives[cleanest_value(:add_life)] ||={}
    
    add_life_username_validator

  end # ======== validator :add_life
  
  def add_life_username_validator

    sanitize {
      
      # Delete invalid characters and 
      # reduce any suspicious characters. 
      # '..*' becomes '.', '--' becomes '-'
      with(/[^a-z0-9]{1,}/i) { |s|
        if ['_', '.', '-'].include?( s[0,1] )
          s[0,1]
        else
          ''
        end
      }
      
    }

    must_be {

      min_size 2,  'Username is too small. It must be at least 2 characters long.'
			max_size 20, 'Username is too large. The maximum limit is: 20 characters.'
			
			valid_chars    = "A-Z a-z 0-9 . _ -"
			invalid_regexp = /[^a-zA-Z0-9\.\_\-]/
      not_match( invalid_regexp, 'Username can only contain the follow characters: #{valid_chars}' ) 

    } 

    new_data.lives[cleanest_value(:add_life)][:username] = cleanest_value(:add_life_username)
    
    if errors.empty?
      begin
        reserve_username( cleanest_value(:add_life_username) )
      rescue Couch_Doc::HTTP_Error_409_Update_Conflict
        errors << "Username already taken: #{add_life_username}"
      end
    end

  end # validator :add_life_username

  private # ==================================================

	def reserve_username new_un
		this_id = if new?
								if new_data._id
									new_data._id
								else
									new_data._id = Couch_Doc.GET_uuid
								end
							else
								_id
							end
		doc_id = 'username-' + new_un
		Couch_Doc.PUT( doc_id,  {:member_id=>this_id} )
	end

  def add_to_history(hash)
    if !hash.is_a?(Hash)
      raise ArgumentError, "Only Hash object is allowed."
    end

    hash[:timestamp] = Time.now.utc.strftime(Time_Format) 

    self.new_data.history ||= self.history
    self.history << hash
  end

end # === model Member




