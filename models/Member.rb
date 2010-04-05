require 'bcrypt'

class Member 

  include Couch_Plastic

  def self.db_collection
    @coll ||= DB.collection('Members')
  end

  enable_timestamps
  
  psuedo_fields :add_username,
                :update_username,
                :password, 
                :confirm_password

  [ 
    :data_model, 
    :hashed_password, 
    :salt,
    :security_level,
    :lang ].each { |f| make f, :not_empty}
               

  make :security_level, [:in_array, Security_Levels]
  
  make :email, 
    :string, 
    [:stripped, /[^a-z0-9\.\-\_\+\@]/i ],
    [:match, /\A[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]\Z/ ],
    [:min, 6],
    [:equal, lambda { raw_data[:email] } ],
    [:error_msg, 'Email has invalid characters.']

  make :add_life_username, 
    # Delete invalid characters and 
    # reduce any suspicious characters. 
    # '..*' becomes '.', '--' becomes '-'
    [:stripped, /[^a-z0-9]{1,}/i, lambda { |s|
        if ['_', '.', '-'].include?( s[0,1] )
          s[0,1]
        else
          ''
        end
      }], 
     [:min, 2, 'Username is too small. It must be at least 2 characters long.'],
     [:max, 20, 'Username is too large. The maximum limit is: 20 characters.'],
     [:not_match, /[^a-zA-Z0-9\.\_\-]/, 'Username can only contain the follow characters: A-Z a-z 0-9 . _ -']
  
  make :password, 
      :stripped,
      [:min, 5],
      [:equal, lambda { doc.raw_data[:confirm_password] }, 'Password and password confirmation do not match.' ],
      [:match, /[0-9]/, 'Password must have at least one number' ],
      [:if_valid, lambda {
          new_data.salt = begin
                            # Salt and encrypt values.
                            chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
                            (1..10).inject('') { |new_pass, i|  
                              new_pass += chars[rand(chars.size-1)] 
                              new_pass
                            }
                          end

          new_data.hashed_password = BCrypt::Password.create( cleanest(:password) + new_data.salt ).to_s
      }]
      
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

  #VALID_USERNAME_FORMAT = /\A[a-zA-Z0-9\-\_\.]{2,25}\z/
  #VALID_USERNAME_FORMAT_IN_WORDS = "letters, numbers, underscores, dashes and periods."

  # ==== Class Methods =====================================================    

  def self.valid_security_level?(perm_level)
    SECURITY_LEVELS.include?(perm_level) || 
      perm_level.to_s['username-'] ||
        perm_level.to_s['member-'] 
  end
  
  def self.db_collection_usernames
    @coll_usernames ||= DB.collection('Member_Usernames')
  end

  def self.db_collection_failed_attempts
    @coll_failed_attempts ||= DB.collection('Member_Failed_Attempts')
  end

  def self.db_collection_password_resets
    @coll_password_resets ||= DB.collection('Member_Password_Resets')
  end

  # ==== Getters =====================================================    
  
  def self.by_username raw_username
    username = raw_username.to_s.strip
    doc = db_collection_usernames.find_one( :_id => username )
    if doc && !username.empty?
      Member.new(doc['owner_id'])
    else
      raise Couch_Plastic::Not_Found, "Member Username: #{username.inspect}"
    end
  end

  def self.failed_attempts_for_today mem, &blok

    db_collection_failed_attempts.find( 
       :owner_id => mem.data._id,  
       :_id => { :$lt => Couch_Plastic.utc_date_now,
                 :$gte => Couch_Plastic.utc_string(Time.now.utc - (60*60*24))
       },
       &blok
    )
  end
  
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
      db_collection_password_resets.find_one(:_id=>pass_reset_id)
      raise Password_Reset, mem.inspect
    rescue Couch_Plastic::Not_Found
      nil
    end

    correct_password = BCrypt::Password.new(mem.data.hashed_password) === (password + mem.data.salt)

    return mem if correct_password

    # Grab failed attempt count.
    fail_count = Member.failed_attempts_for_today(mem).count
    new_count  = fail_count + 1
    
    # Insert failed password.
    db_collection_failed_attempts.insert(
      :data_model => 'Member_Failed_Attempt',
      :owner_id   => mem.data._id, 
      :date       => Couch_Plastic.utc_date_now, 
      :time       => Couch_Plastic.utc_time_now,
      :ip_address => ip_addr,
      :user_agent => user_agent
    )

    # Raise Account::Reset if necessary.
    if new_count > 2
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
      new_data.security_level = Member::MEMBER
      ask_for :avatar_link, :email
      demand  :add_life, :password
      save_create 
      db_collection_usernames.insert(
        :username   => clean_data[:username],  
        :owner_id   => data._id
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
    assoc_cache[:usernames] ||= begin
      self.db_collection_usernames.find(:owner_id=>data._id).map { |un|
        un['username']
      }
    end
  end

  def username_ids
    assoc_cache[:username_ids] ||= begin
                                     self.db_collection_usernames.find(:owner_id=>data._id).map { |un|
                                       un['_id']
                                     }
                                   end
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
    
    if raw_level.is_a?(String)  
      return true if usernames.include?(raw_level)
      return true if data._id === raw_level
      return true if username_ids.include?(raw_level)
    end

    target_level = raw_level.to_s
    if !self.class.valid_security_level?(target_level)
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

  
end # === model Member




