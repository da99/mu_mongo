require 'bcrypt'

class Member 

  include Couch_Plastic

  enable_timestamps
  
  allow_proto_fields :add_life, :add_life_username,
                     :update_life, :update_life_username,
                     :password, :confirm_password

  allow_fields :lives, 
               :data_model, 
               :hashed_password, 
               :salt,
               :security_level,
							 :lang
							 

  # =========================================================
  #                     CONSTANTS
  # =========================================================  
  
  Wrong_Password         = Class.new( StandardError )
  Password_Reset         = Class.new( StandardError )
  Invalid_Security_Level = Class.new( StandardError )

  SECURITY_LEVELS        = %w{ NO_ACCESS STRANGER  MEMBER  EDITOR   ADMIN }
  SECURITY_LEVELS.each do |k|
    const_set k, k
  end
  
  EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/
  LIVES = %w{
      friend
      work
      family
      pet-owner
  }.freeze

  #VALID_USERNAME_FORMAT = /\A[a-zA-Z0-9\-\_\.]{2,25}\z/
  #VALID_USERNAME_FORMAT_IN_WORDS = "letters, numbers, underscores, dashes and periods."

  # ==== Class Methods =====================================================    

  def self.valid_security_level?(perm_level)
    SECURITY_LEVELS.include?(perm_level)
  end

  # ==== Getters =====================================================    
  
  def self.by_username raw_username
    username = raw_username.to_s.strip
    if username.empty?
      raise Couch_Doc::Not_Found, "Member: #{raw_username.inspect}"
    end
    doc = CouchDB_CONN.GET_by_view( :member_usernames, 
                  :key=>username, 
                  :limit=>1, 
                  :include_docs=>true
    )
    Member.new(doc[:doc])
  end

  def self.GET_failed_attempts_for_today mem

    CouchDB_CONN.GET_by_view(
      :member_failed_attempts, 
      {:startkey => [mem.data._id, Couch_Plastic.utc_date_now],
       :endkey   => [mem.data._id, Couch_Plastic.utc_string(Time.now.utc + (60*60*24)).split(' ').first ]
      }
    )[:rows]
      
  end
  
  # def self.GET_old_failed_attempts mem

  #   start_date = Couch_Plastic.utc_string(Time.now.utc - (60*60*24*2))
  #   CouchDB_CONN.GET_by_view(
  #     :member_failed_attempts, 
  #     {:startkey => "#{Couch_Plastic.utc_string(Time.now.utc + (60*60*24*2))}-#{mem.data._id}",
  #      :include_docs => true
  #     }
  #   ).map { |row| row[:doc] }
  #     
  # end
  
  # Based on Sinatra-authentication (on github).
  # 
  # Parameters:
  #   raw_vals - Hash with at least 2 keys: :username, :password
  # 
  # Raises: 
  #   Member::Wrong_Password
  #
  def self.authenticate( raw_vals )

    username, password = raw_vals.values_at(:username, :password).map(&:to_s).map(&:strip)
    ip_addr, user_agent = raw_vals.values_at(:ip_address, :user_agent).map(&:to_s).map(&:strip)
    
    ip_addr    = nil if ip_addr.empty?
    user_agent = nil if user_agent.empty?

    if username.empty? || password.empty?
      raise Wrong_Password, "#{raw_vals.inspect}"
    end

    mem = Member.by_username( username )

    # Check for Password_Reset
    pass_reset_id = "#{mem.data._id}-password-reset"
    begin
      CouchDB_CONN.GET(pass_reset_id)
      raise Password_Reset, mem.inspect
    rescue Couch_Doc::Not_Found
      nil
    end

    correct_password = BCrypt::Password.new(mem.data.hashed_password) === (password + mem.data.salt)

    return mem if correct_password

    # Grab failed attempt count.
    fail_count = Member.GET_failed_attempts_for_today(mem).size
    new_count  = fail_count + 1
    
    # Insert failed password.
    CouchDB_CONN.PUT(
      "#{Couch_Plastic.utc_date_now}-#{mem.data._id}-failed-attempt-#{Time.now.utc.to_i}-#{new_count}", 
      { :data_model => 'Member_Failed_Attempt',
        :count      => new_count, 
        :member_id  => mem.data._id, 
        :date       => Couch_Plastic.utc_date_now, 
        :time       => Couch_Plastic.utc_time_now,
        :ip_address => ip_addr,
        :user_agent => user_agent
      }
    )
    
    # Delete old failed attempts.
    # old_docs = Member.GET_old_failed_attempts(mem)
    # if not old_docs.empty?
    #   CouchDB_CONN.bulk_DELETE( old_docs )
    # end

    # Raise Account::Reset if necessary.
    if new_count > 2
      CouchDB_CONN.PUT(pass_reset_id,  :time=>Couch_Plastic.utc_now )
      raise Password_Reset, mem.inspect
    end

    raise Wrong_Password, "Password is invalid for: #{username.inspect}"
  end 

  # ==== Authorizations ====

  def creator? editor # NEW, CREATE
    return true if !editor
    false
  end

  def self.create editor, raw_raw_data # CREATE
    d = new(nil, editor, raw_raw_data) do
      new_data._id            = "member-#{CouchDB_CONN.GET_uuid}"
      new_data.security_level = Member::MEMBER
      ask_for :avatar_link, :email
      demand  :add_life, :password
      save_create 
      CouchDB_CONN.PUT(
        "member-life-friends-#{data._id}",
        :data_model => 'Member_Life', 
        :username   => clean_data[:username],  
        :title      => 'Friends',
        :category   => 'casual'
      )
    end
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

  def self.update id, editor, new_raw_data # UPDATE

    doc = new(id, editor, new_raw_data) do
      ask_for :old_life, :add_life 

      if manipulator == self
        ask_for :password  
      end

      if manipulator.has_power_of? ADMIN
        ask_for :security_level
      end
      
      save_update 
    end

  end

  def deletor? editor # DELETE
    updator? editor
  end


  # ==== ACCESSORS =====================================================

  def lang
    'en-us'
  end

  # 
  # By using a custom implementation, we cane make sure
  # sensitive information is not shown.
  #
  def inspect
    assoc_cache[:inspect_string] ||= "#<#{self.class}:#{self.object_id} id=#{self.data._id}>"
  end
  
  def usernames
    assoc_cache[:usernames] ||= data.lives.values.map { |l| l[:username]}
  end

	def username_ids
		assoc_cache[:username_ids] ||= usernames.map {|un| "username-#{un}"}
	end

  def human_field_name col
    case col
      when :add_life_username, 'add_life_username'
        "username"
      else
        super(col)
    end
  end

  def has_power_of?(raw_level)

    return true if raw_level == self
    
    target_level = raw_level.to_s

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

    must_be {
			stripped
      min_size 5
      equal doc.raw_data[:confirm_password], 'Password and password confirmation do not match.'
      match( /[0-9]/, 'Password must have at least one number' )
    }
    
    if errors.empty?
      new_data.salt = begin
                        # Salt and encrypt values.
                        chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
                        (1..10).inject('') { |new_pass, i|  
                          new_pass += chars[rand(chars.size-1)] 
                          new_pass
                        }
                      end

      new_data.hashed_password = BCrypt::Password.create( cleanest(:password) + new_data.salt ).to_s
    end
  end
  
  def security_level_validator 
    must_be! { 
      in_array Security_Levels 
    }
  end # === def set_security_level
  
 
  def email_validator  

    valid_email_chars   = /\A[a-zA-Z0-9\.\-\_\+\@]{8,}\z/
    email_finder        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
    valid_email_format  = /\A#{email_finder}\z/

    must_be {
      string
      stripped(  /[^a-z0-9\.\-\_\+\@]/i  )
      min_size 6
      equal raw_data[:email], 'Email has invalid characters.'
      
    }
  
  end # === def email=
  
  def add_life_validator 
    
    must_be! {
      in_array Member::LIVES
    }
      
    if new?
      new_data.lives = {}
    else
      must_be! {
        not_in_array doc.data.lives.keys
      }
    end
    
    new_data.lives[cleanest(:add_life)] ||={}
    
    add_life_username_validator

  end # ======== validator :add_life
  
  def add_life_username_validator

    must_be {

      # Delete invalid characters and 
      # reduce any suspicious characters. 
      # '..*' becomes '.', '--' becomes '-'
      stripped(/[^a-z0-9]{1,}/i) { |s|
        if ['_', '.', '-'].include?( s[0,1] )
          s[0,1]
        else
          ''
        end
      }
      
      min_size 2,  'Username is too small. It must be at least 2 characters long.'
			max_size 20, 'Username is too large. The maximum limit is: 20 characters.'
			
      not_match( 
        /[^a-zA-Z0-9\.\_\-]/, 
        'Username can only contain the follow characters: A-Z a-z 0-9 . _ -' 
      ) 

    } 

    new_data.lives ||= {}
    new_data.lives[cleanest(:add_life)] ||= {}
    new_data.lives[cleanest(:add_life)][:username] = cleanest(:add_life_username)
    
    if errors.empty?
      begin
        reserve_username( cleanest :add_life_username  )
      rescue Couch_Doc::HTTP_Error_409_Update_Conflict
        errors << "Username already taken: #{cleanest(:add_life_username)}"
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
		CouchDB_CONN.PUT( doc_id,  {:member_id => this_id, :username => new_un, :data_model => 'Reserved_Username'} )
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




