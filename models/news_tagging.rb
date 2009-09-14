class NewsTagging < Sequel::Model

  # ==== CONSTANTS =====================================================
  
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  many_to_one :tag, :class_name=>'NewsTag', :key=>:tag_id
  
  # ==== HOOKS =========================================================


  # ==== CLASS METHODS =================================================


  # ==== INSTANCE METHODS ==============================================

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

end # === end NewsTagging
