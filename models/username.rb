class Username < Sequel::Model

  # ==== CONSTANTS =====================================================
  EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  many_to_one :owner, :class_name=>'Member', :key=>:owner_id
  
  # ==== HOOKS =========================================================
  

  
  # ==== CLASS METHODS =================================================


  # ==== INSTANCE METHODS ==============================================

  def_create  do
    allow_only :MEMBER
    self[:owner_id] = current_editor[:id]
    require_columns :username
    optional_columns :nickname, :category
  end
  
  def_update do
  
    allow_only self.owner, :ADMIN
    required_columns_if_exist :username, :nickname, :category, :email 
    
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
  
  def_after_update do
    
    return true if !@history_msgs.empty?
    
    HistoryLog.create_it!( 
     :owner_id  => self.owner[:id], 
     :editor_id => self.current_editor[:id], 
     :action    => 'UPDATE', 
     :body      => @history_msgs.join("\n")
    ) 
    
  end  
  

  def_validator( :email ) { 
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
              
  } # === def set_email
  
  
  def_validator( :username ) {
    fn = :username
    raw_name = raw_data[fn].to_s.strip
    
    # Delete invalid characters and 
    # reduce any suspicious characters. 
    # '..*' becomes '.', '--' becomes '-'
    new_un = raw_name.gsub( /[^a-z0-9]{1,}/i  ) { |s| 
                                                      ['_', '.', '-'].include?( s[0,1] ) ?
                                                        s[0,1] :
                                                        '' ;
                                                    }          
    
    # Check to see if there is at least one alphanumeric character          
    self.errors.add( fn,  
                    'Username is too short. (Must be 3 or more characters.)' 
                   ) if new_un.length < 2
    self.errors.add( fn,  
                    'Username is too long. (Must be 20 characters or less.)' 
                   ) if new_un.length > 20
    self.errors.add( fn,  
                    'Username must have at least one letter or number.' 
                   ) if !new_un[ /[a-z0-9]/i ] && self.errors.empty?
    
    return( self[fn] = new_un ) if self.errors[fn].empty?
    nil 
    
  } # === def validate_new_values
  
  
end # === end Username


