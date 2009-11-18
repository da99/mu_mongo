class Project < Sequel::Model

  # ==== CONSTANTS =====================================================
  
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  
  def todos
  end
  
  # ==== HOOKS =========================================================


  # ==== CLASS METHODS =================================================

  def creator? editor
  end

  def updator? editor
    editor && (editor._id == self._id)
  end

  # ==== INSTANCE METHODS ==============================================


end # === end Project
