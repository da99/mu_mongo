
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


  # ==== HOOKS =========================================================
  

  
  # ==== CLASS METHODS =================================================




  def self.create editor, raw_vals
    new_doc = new
    new_doc.validate_editor( editor, MEMBER )
    new_doc.owner_id= raw_vals
    new_doc.username= raw_vals
    new_doc.set_optional_values raw_vals, :nickname, :category
    new_doc.save_create
  end

  def self.edit editor, raw_vals
    doc = CouchDoc.GET_by_id(raw_vals[:id]) 
    doc.validate_editor( editor, doc.owner, :ADMIN  )
    doc
  end

  def self.update editor, raw_vals
    doc = edit(editor, raw_vals)
    doc.set_optional_values raw_vals, :username, :nickname, :category, :email 

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

    doc.save_update
  end # === def update_it!


  # ==== INSTANCE METHODS ==============================================


  # Association to Member, through :owner_id
  def owner
    CouchDoc.GET_by_id( self.original[:owner_id] )
  end


  def owner_id= raw_params
    fn = :owner_id
    nv = raw_params[fn]
    if !nv
      self.errors << "Owner not specified."
      return nil
    end

    self.new_values[fn] = Integer(nv)
  end

  
  def email= raw_params
    fn = :email
    v = raw_params[ fn ] 

    with_valid_chars = v.to_s.gsub( /[^a-z0-9\.\-\_\+\@]/i , '')

    if with_valid_chars != raw_params[fn] || with_valid_chars !~ VALID_EMAIL_FORMAT 
      self.errors << "Email contains invalid characters." 
    end

    if with_valid_chars.length < 6
      self.errors << "Email is too short." 
    end
  
    if self.errors.empty?
      self.new_values[fn] = with_valid_chars  
      return self.new_values[fn]
    end

    nil
  end # === def email=
  
  
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
      self.errors << 'Username is required.'
    elsif new_un.length < 2
      self.errors << 'Username is too short. (Must be 3 or more characters.)' 
    elsif new_un.length > 20
      self.errors << 'Username is too long. (Must be 20 characters or less.)' 
    elsif !new_un[ /[a-z0-9]/i ] && self.errors.empty?
      self.errors << 'Username must have at least one letter or number.' 
    end
    
    if self.errors.empty?
      self.new_values[fn] = new_un
      self.new_values[:_id] = "username-#{new_un}"
      return new_un
    end

    nil
  end # === def validate_new_values
  
  
end # === end Username


