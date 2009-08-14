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
    
    new_un.require_fields raw_params, :owner_id, :username
    
    new_un.optional_fields raw_params, :nickname, :category
    
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
    
    optional_fields raw_params,  :username, :nickname, :category, :email 
    
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
  
  
  def_set_meth( :owner_id ) { | rec, fn, raw_params |

    if raw_params[ fn ].to_i < 1
      rec.errors[ fn ] << "Member id is required." 
    end
    
    return nil if !rec.errors[:id].empty?
    
    rec[ fn ] = rec.raw_params[ fn ] 
    
  } # === def set_id
  

  def_set_meth( :email ) { |rec, fn, raw_params|

    v = raw_params[ fn ] 
    return( rec[ fn ] = nil ) if v.nil? || v.strip.empty?

    
    with_valid_chars = v.to_s.gsub( /[^a-z0-9\.\-\_\+\@]/i , '')
    
    rec.errors.add( fn, 
                    "Email contains invalid characters." 
                    ) if with_valid_chars != raw_email || with_valid_chars !~ VALID_EMAIL_FORMAT 
    
    rec.errors.add( fn,  
                     "Email is too short." 
                    ) if with_valid_chars.length < 6
  
    return nil if !rec.errors[fn].empty?
    
    rec[fn] = with_valid_chars
    
    #begin
    #  require 'tmail'
    #  validated_email = TMail::Address.parse( email_address ).to_s
    #rescue TMail::SyntaxError
    #  raise( Sequel::ValidationFailed,  "Invalid Format: Email format could not be recognized."  )
              
  } # === def set_email
  
  
  def_set_meth( :username ) { |rec, fn, raw_params|
    
    raw_name = raw_params[fn]
    
    # Delete invalid characters and 
    # reduce any suspicious characters. 
    # '..*' becomes '.', '--' becomes '-'
    sanitized = raw_name.gsub( /[^a-z0-9]{2,}/i  ) { |s| 
                                                      ['_', '.', '-'].include?( s[0,1] ) ?
                                                        s[0,1] :
                                                        '' ;
                                                    }          
    
    # Check to see if there is at least one alphanumeric character          
    rec.errors.add( fn,  
                    'Username is empty.' 
                   ) if sanitized.empty?
    rec.errors.add( fn,  
                    'Username is too short. (Must be 3 or more characters.)' 
                   ) if sanitized.length < 2
    rec.errors.add( fn,  
                    'Username is too long. (Must be 20 characters or less.)' 
                   ) if sanitized.length > 20
    rec.errors.add( fn,  
                    'Username must have at least one letter or number.' 
                   ) if !sanitized[ /[a-z0-9]/i ]
    
    return nil if !rec.errors[fn].empty?
    
    rec[fn] = sanitized
    
  } # === def validate_new_values
  
end # === end Username
