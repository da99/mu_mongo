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

  def validate_create( raw_params )
    raw_params[:owner_id] = raw_params[:EDITOR][:id]
    required_fields raw_params, :owner_id, :username
    optional_fields raw_params, :nickname, :category
  end
  
  def validate_update( raw_params )
    
    @history_msgs = []
    @editor = raw_params[:EDITOR]
    
    raw_params.each { |k,v|
      case k.to_sym
        when :username
          history_msgs << "Changed username from: #{self[:username]}"
        when :email
          history_msgs << "Changed email from: #{self[:email]}"
      end
    }
    
    optional_fields raw_params,  :username, :nickname, :category, :email 
    
  end # === def update_it!
  
  
  def after_update
    if !@history_msgs.empty?
      HistoryLog.create_it!( 
       :owner_id=>self.owner[:id], 
       :editor_id=>@editor[:id], 
       :action=>'UPDATE', 
       :body=>@history_msgs.join("\n")
      ) 
    end
  end
  
  
  def has_permission?(action, editor)
    case action
      when :create
        true
      when :update
        editor == self.owner
      else
        false
    end
  end # === def editor?
   

  def_setter( :email ) {  |raw_params|
    fn = :email
    v = raw_params[ fn ] 
    return( self[ fn ] = nil  ) if v.nil? || v.strip.empty?
      

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
  
  
  def_setter( :username ) { | raw_params |
    fn = :username
    raw_name = raw_params[fn].to_s.strip
    
    # Delete invalid characters and 
    # reduce any suspicious characters. 
    # '..*' becomes '.', '--' becomes '-'
    sanitized = raw_name.gsub( /[^a-z0-9]{2,}/i  ) { |s| 
                                                      ['_', '.', '-'].include?( s[0,1] ) ?
                                                        s[0,1] :
                                                        '' ;
                                                    }          
    
    # Check to see if there is at least one alphanumeric character          
    self.errors.add( fn,  
                    'Username is too short. (Must be 3 or more characters.)' 
                   ) if sanitized.length < 2
    self.errors.add( fn,  
                    'Username is too long. (Must be 20 characters or less.)' 
                   ) if sanitized.length > 20
    self.errors.add( fn,  
                    'Username must have at least one letter or number.' 
                   ) if !sanitized[ /[a-z0-9]/i ] || self.errors.empty?
    
    if !self.errors[fn].empty?
      nil 
    else
      self[fn] = sanitized
    end
    
  } # === def validate_new_values
  
end # === end Username
