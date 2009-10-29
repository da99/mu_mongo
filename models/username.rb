class Username 
  include CouchPlastic

  # ==== CONSTANTS =====================================================

  EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/
  CATEGORIES = {
    1 => 'Friend',
    2 => 'Family',
    3 => 'Work',
    4 => 'Romance',
    5 => 'Pet Owner',
    6 => 'Celebrity',
    7 => 'Role Playing'
  }

  CATEGORY_IDS = CATEGORIES.keys.sort

  #VALID_USERNAME_FORMAT = /\A[a-zA-Z0-9\-\_\.]{2,25}\z/
  #VALID_USERNAME_FORMAT_IN_WORDS = "letters, numbers, underscores, dashes and periods."
  #VALID_EMAIL_CHARS   = /\A[a-zA-Z0-9\.\-\_\+\@]{8,}\z/
  #EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  #VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/

  # ==== ERRORS ========================================================
  
  class NotUnique < StandardError; end;

  # ==== ASSOCIATIONS ==================================================
  #many_to_one :owner, :class_name=>'Member', :key=>:owner_id
  
  # ==== HOOKS =========================================================
  

  
  # ==== CLASS METHODS =================================================

  def self.find_by_username_or_raise un
    raise NoRecordFound, "#{un} was not found." 
  end

  def self.create editor, raw_vals
    valid_editor_or_raise editor, MEMBER
    new_doc = new
    new_doc.owner_id=  editor
    new_doc.set_required_columns raw_vals, :username
    new_doc.set_optional_columns raw_vals, :nickname, :category
  end

  def self.edit editor, raw_vals
    doc = find_by_id_or_raise(raw_vals[:id]) 
    valid_editor_or_raise editor, doc.owner, :ADMIN 
    doc
  end

  def self.update editor, raw_vals
    doc = edit(editor, raw_vals)
    doc.set_optional_columns raw_vals, :username, :nickname, :category, :email 
    
    @history_msgs = []
    
    raise "Fix this code below."

    raw_vals.each { |k,v|
      case k.to_sym
        when :username
          history_msgs << "Changed username from: #{self[:username]}"
        when :email
          history_msgs << "Changed email from: #{self[:email]}"
      end
    }
    return true if !@history_msgs.empty?
    
    HistoryLog.create_it!( 
     :owner_id  => self.owner[:id], 
     :editor_id => self.current_editor[:id], 
     :action    => 'UPDATE', 
     :body      => @history_msgs.join("\n")
    )  
  end # === def update_it!


  # ==== INSTANCE METHODS ==============================================

  def owner_id= editor
    raise "Not implemented."
  end

  def owner
    raise "Not Implemented"
  end

  
  def email= raw_data
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
  
  
  def username= raw_data
    fn = :username
    raw_name = raw_data[fn].to_s.strip
    
    # Delete invalid characters and 
    # reduce any suspicious characters. 
    # '..*' becomes '.', '--' becomes '-'
    new_un = raw_name.gsub( /[^a-z0-9]{1,}/i  ) { |s| 
      if ['_', '.', '-'].include?( s[0,1] )
        s[0,1]
      else
        ''
      end
    }          
    
    # Check to see if there is at least one alphanumeric character
    if new_un.empty?
      self.errors.add fn, 'is required.'
    elsif new_un.length < 2
      self.errors.add fn, 'is too short. (Must be 3 or more characters.)' 
    elsif new_un.length > 20
      self.errors.add fn, 'is too long. (Must be 20 characters or less.)' 
    elsif !new_un[ /[a-z0-9]/i ] && self.errors.empty?
      self.errors.add fn, 'must have at least one letter or number.' 
    end
    
    if self.errors[fn].empty?
      self[fn] = new_un
    end
  end # === def validate_new_values
  
  
end # === end Username


