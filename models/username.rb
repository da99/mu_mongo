class Username < Sequel::Model

  # ==== CONSTANTS =====================================================
  EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  many_to_one :owner, :class_name=>'Member', :key=>:owner_id
  
  # ==== HOOKS =========================================================
  

  # ==== CLASS METHODS =================================================

  def self.create_it!( raw_params )
    new_un = new
    
    # Required fields.
    new_un.set_owner_id raw_params
    new_un.set_username raw_params
    
    # Optional fields.
    new_un.set_these( raw_params, [ :nickname, :category] )
    
    un.save_it!( raw_params )
  end

  # ==== INSTANCE METHODS ==============================================

  def update_it!( raw_params )
    
    history_msgs = []
    
    raw_params.each { |k,v|
      case k.to_sym
        when :username
          history_msgs << "Changed username from: #{self[:username]}"
        when :email
          history_msgs << "Changed email from: #{self[:email]}"
      end
    }
    
    set_these( raw_params, [ :username, :nickname, :category, :email ] )
    
    if save_it!(raw_params) && !history_msgs.empty?
      HistoryLog.create_it!( 
       :owner_id=>self.owner.id, 
       :editor_id=>editor.id, 
       :action=>'UPDATE', 
       :body=>history_msgs.join("\n")
      ) 
    end
    
  end # === def update_it!
  
  
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
  
  
  def set_owner_id( raw_params )        
  
    if raw_params[:owner_id].to_i < 1
      errors[:owner_id] << "Member id is required." 
    end
    
    return nil if !errors[:id].empty?
    
    self[:owner_id] = raw_params[:owner_id] 
    
  end # === def set_id
  

  def set_email( raw_params )

    v = raw_params[:email] 
    return( self[:email] = nil ) if v.nil? || v.strip.empty?

    
    with_valid_chars = v.to_s.gsub( /[^a-z0-9\.\-\_\+\@]/i , '')
    
    self.errors.add( :email, 
                    "Email contains invalid characters." 
                    ) if with_valid_chars != raw_email || with_valid_chars !~ VALID_EMAIL_FORMAT 
    
    self.errors.add( :email,  
                     "Email is too short." 
                    ) if with_valid_chars.length < 6
  
    return nil if !self.errors[:email].empty?
    
    self[:email] = with_valid_chars
    
    #begin
    #  require 'tmail'
    #  validated_email = TMail::Address.parse( email_address ).to_s
    #rescue TMail::SyntaxError
    #  raise( Sequel::ValidationFailed,  "Invalid Format: Email format could not be recognized."  )
              
  end # === def set_email
  
  
  def set_username( raw_params)
    
    raw_name = raw_params[:username]
    
    # Delete invalid characters and 
    # reduce any suspicious characters. 
    # '..*' becomes '.', '--' becomes '-'
    sanitized = raw_name.gsub( /[^a-z0-9]{2,}/i  ) { |s| 
      ['_', '.', '-'].include?( s[0,1] ) ?
        s[0,1] :
        '' ;
    }          
    
    # Check to see if there is at least one alphanumeric character          
    self.errors.add( :username,  
                    'Username is empty.' 
                   ) if sanitized.empty?
    self.errors.add( :username,  
                    'Username is too short. (Must be 3 or more characters.)' 
                   ) if sanitized.length < 2
    self.errors.add( :username,  
                    'Username is too long. (Must be 20 characters or less.)' 
                   ) if sanitized.length > 20
    self.errors.add( :username,  
                    'Username must have at least one letter or number.' 
                   ) if !sanitized[ /[a-z0-9]/i ]
    
    return nil if !self.errors[:username].empty?
    
    self[:username] = sanitized
    
  end # === def validate_new_values
  
  
end # === end Username
