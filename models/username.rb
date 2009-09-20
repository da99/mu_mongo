class Username < Sequel::Model

  # ==== CONSTANTS =====================================================
  EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/
 
  #VALID_USERNAME_FORMAT = /\A[a-zA-Z0-9\-\_\.]{2,25}\z/
  #VALID_USERNAME_FORMAT_IN_WORDS = "letters, numbers, underscores, dashes and periods."
  #VALID_EMAIL_CHARS   = /\A[a-zA-Z0-9\.\-\_\+\@]{8,}\z/
  #EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  #VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  many_to_one :owner, :class_name=>'Member', :key=>:owner_id
  
  # ==== HOOKS =========================================================
  

  
  # ==== CLASS METHODS =================================================

  def self.validate_username(u)
    err, new_u = get_username_errors(u)
    raise(Sequel::ValidationFailed, "Username #{err}") if err
    return new_u
  end

  # Returns either a string representing the error 
  # or an Array when first value is nil (no errors) and
  # second value is sanitized username.
  def self.get_username_errors(u)
    fn = :username
    raw_name = u.to_s.strip
    
    # Delete invalid characters and 
    # reduce any suspicious characters. 
    # '..*' becomes '.', '--' becomes '-'
    new_un = raw_name.gsub( /[^a-z0-9]{1,}/i  ) { |s| 
                                                      ['_', '.', '-'].include?( s[0,1] ) ?
                                                        s[0,1] :
                                                        '' ;
                                                    }          
    
    # Check to see if there is at least one alphanumeric character
    if new_un.empty?
      return 'is required.'
    elsif new_un.length < 2
      return 'is too short. (Must be 3 or more characters.)' 
    elsif new_un.length > 20
      return 'is too long. (Must be 20 characters or less.)' 
    elsif !new_un[ /[a-z0-9]/i ] && self.errors.empty?
      return 'must have at least one letter or number.' 
    end
    
    [nil, new_un] 
  end

  # ==== INSTANCE METHODS ==============================================

  allow_creator :MEMBER do
    self[:owner_id] = current_editor[:id]
    require_columns :username
    optional_columns :nickname, :category
  end
  
  allow_updator :owner, :ADMIN  do
  
    optional_columns :username, :nickname, :category, :email 
    
    @history_msgs = []
    
    raw_data.each { |k,v|
      case k.to_sym
        when :username
          history_msgs << "Changed username from: #{self[:username]}"
        when :email
          history_msgs << "Changed email from: #{self[:email]}"
      end
    }
    
  end # === def update_it!
  
  def after_update
    
    return true if !@history_msgs.empty?
    
    HistoryLog.create_it!( 
     :owner_id  => self.owner[:id], 
     :editor_id => self.current_editor[:id], 
     :action    => 'UPDATE', 
     :body      => @history_msgs.join("\n")
    ) 
    
  end  
  

  validator :email do
    raw_params = raw_data
    fn = :email
    v = raw_params[ fn ] 

    with_valid_chars = v.to_s.gsub( /[^a-z0-9\.\-\_\+\@]/i , '')
    
    self.errors.add( fn, 
                    "Email contains invalid characters." 
                    ) if with_valid_chars != raw_email || with_valid_chars !~ VALID_EMAIL_FORMAT 
    
    self.errors.add( fn,  
                     "Email is too short." 
                    ) if with_valid_chars.length < 6
  
    return( self[fn] = with_valid_chars ) if self.errors[fn].empty?
    
    nil
              
  end # === def _email_
  
  
  validator :username do
    fn = :username
    err, new_u = self.class.get_username_errors(raw_data[fn])
    if err
      self.errors.add( fn, err )
    else
      self[fn] = new_u
    end
  end # === def validate_new_values
  
  
end # === end Username


