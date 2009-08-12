class Username < Sequel::Model

  # ==== CONSTANTS =====================================================
  EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  many_to_one :owner, :class_name=>'Member'
  
  # ==== HOOKS =========================================================
  

  # ==== CLASS METHODS =================================================

  def self.create_it( raw_params )
    allowed_params = filter_params( raw_params, [:owner, :name, :nickname, :category] )
    un = new
    un.set un.wash_values( allowed_params )
    un.require_string! :name
    un.require_assoc! :owner
    un.save
  end

  # ==== INSTANCE METHODS ==============================================

  def columns_for_editor( params, mem )
        
    if mem 
      if mem.admin? || self.owner == mem
        return [ :username, :email ]
      end
    end
    
  end # === def changes_from_editor

  def validate_new_values( raw_params , editor = nil)
  
    cols            = columns_for_editor( raw_params, editor )
    allowed_params  = raw_params.values_at( *cols )    
    clean_params    = {}
    
    allowed_params.each do |k,v|
    
      case k.to_sym
      
        when :email
            with_valid_chars = v.to_s.gsub( /[^a-z0-9\.\-\_\+\@]/i , '')
            
            self.errors.add( :email, 
                            "Email contains invalid characters." 
                            ) if with_valid_chars != raw_email
            
            self.errors.add( :email,  
                             "Email is too short." 
                            ) if with_valid_chars.length < 6

            #begin
            #  require 'tmail'
            #  validated_email = TMail::Address.parse( email_address ).to_s
            #rescue TMail::SyntaxError
            #  raise( Sequel::ValidationFailed,  "Invalid Format: Email format could not be recognized."  )
                            
            clean_params[:emails] = with_valid_chars
            
        when :username
        
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
          
          clean_params[:username] = sanitized
          
      end # === case k.to_sym
      
    end # === each
    
    clean_params
    
  end # === def validate_new_values
  
  
  def update_it( raw_params, editor )
    
    orig_vals  = this
    vals       = validate_new_values( raw_params, editor )
    
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
