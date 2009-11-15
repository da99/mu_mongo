
class Username 

  def self.get_by_owner owner_id
    results = CouchDoc.GET(:usernames_by_owner, :key=> owner_id.to_s, :include_docs=>false)
    results[:rows].map { |r| r[:value] }
  end 

  # =========================================================
  #                     CRUD Methods.
  # =========================================================

  enable_timestamps

  required_for_create :owner_id, :username
  optional_for_create :nickname, :category

  required_for_update :history
  optional_for_update :username, :nickname, :category, :email

  # =========================================================
  #           Authorization Methods (Class + Instance)
  # =========================================================
 
  def creator? editor # NEW, CREATE
    return false if !editor
    return true if editor.has_power_of?(:MEMBER)
    false
  end

  def viewer? editor # SHOW
    true
  end

  def updator? editor # EDIT, UPDATE
    return false if !creator?(editor)
    self.owner._id == editor._id
  end

  def deletor? editor # DELETE
    updator?(editor)
  end


  # =========================================================
  #                     SETTERS/ACCESSORS (Instance)
  # =========================================================

  # Association to Member, through :owner_id
  def owner
    Member.by_id( self.original[:owner_id] )
  end


  def owner_id= nv
    fn = :owner_id
    if !nv.is_a?(String)
      raise ArgumentError, "Owner id must be a string: #{nv.inspect}"
    end
    if !nv
      self.errors << "Owner not specified."
      return nil
    end

    self.new_values[fn] = nv
  end

  
end # === class Username


