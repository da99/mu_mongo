class MetaId < Sequel::Model

  # ==== CONSTANTS =====================================================
  
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  
  
  # ==== HOOKS =========================================================


  # ==== CLASS METHODS =================================================


  # ==== INSTANCE METHODS ==============================================

  def has_permission?(*args)
    return true if new?
    false
  end
  
  def __create__
  end
  
  def __update__
  end

end # === end MetaId
