class Username < Sequel::Model

  # ==== CONSTANTS =====================================================
  
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  
  
  # ==== HOOKS =========================================================
  

  # ==== CLASS METHODS =================================================


  # ==== INSTANCE METHODS ==============================================

  def columns_for_editor( params, mem )
    if new?
        self[:owner_id] = mem[:id]
    end
    if [self.owner].include?(mem)
        @current_editor = mem
        @editable_by_editor = []       
    end
    super
  end # === def changes_from_editor

  def validate_it( raw_params , editor = nil)
  
    cols            = columns_for_editor( raw_params, editor )
    allowed_params  = raw_params.values_at( *cols )    
    clean_params    = {}
    
    allowed_params.each do |k,v|
    
      case k.to_sym
      
        when :email
            with_valid_chars = v.to_s.gsub( /[^a-zA-Z0-9\-\_\.\@]/ , '')
            
            self.errors.add( :email, 
                            "Email contains invalid characters." 
                            ) if with_valid_chars != raw_email
            
            self.errors.add( :email,  
                             "Email is too short." 
                            ) if with_valid_chars.length < 4
                            
            clean_params[:emails] = with_valid_chars
            
        when :username
          # Sanitize raw name
          with_valid_chars = raw_name.to_s.gsub( /[^a-zA-Z0-9\-\_\.]/ , '' )
          
          # Reduce any suspicious characters
          sanitized = with_valid_chars.gsub( /[\-\.]{2,}/  ) { |s| s[0,1] }
          
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
          
          clean_params[:username] = sanitized
          
      end # === case k.to_sym
      
    end # === each
    
    clean_params
    
  end # === def validate_new_values
  
  def update_it( raw_params, editor = nil )
    
    orig_vals  = this
    vals       = validate_values( raw_params, editor )
    
    update params
    
    history_msgs = []
    vals.each { |k,v|
      case k.to_sym
        when :username
          history_msgs << "Changed username from: #{orig_vals[:username]}"
        when :email
          history_msgs << "Changed email from: #{orig_vals[:email]}"
      end
    }
    
    
    HistoryLog.create_it( 
     :owner_id=>self.owner.id, 
     :editor_id=>editor.id, 
     :action=>'UPDATE', 
     :body=>history_msgs.join("\n")
    ) if !history_msgs.empty?

    
  end # === def

end # === end Username
