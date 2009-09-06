class News < Sequel::Model

  # ==== CONSTANTS =====================================================
  
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  
  
  # ==== HOOKS =========================================================


  # ==== CLASS METHODS =================================================


  # ==== INSTANCE METHODS ==============================================

  def last_modified
    modified_at || created_at
  end

  def changes_from_editor( params, mem )
    if new?
        self[:owner_id] = mem[:id]
    end
    if [self.owner].include?(mem)
        @current_editor = mem
        @editable_by_editor = []       
    end
    super
  end # === def changes_from_editor

  def validate_new_values
  end # === def validate_new_values

end # === end News
