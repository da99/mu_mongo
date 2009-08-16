class Topic < Sequel::Model

  # ==== CONSTANTS =====================================================
  
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  
  
  # ==== HOOKS =========================================================


  # ==== CLASS METHODS =================================================

  def_alter( :create ) do 
    allow_only :ADMIN   
    required_fields :title
    optional_fields :parent_topic
  end # === create_it
  

  # ==== INSTANCE METHODS ==============================================
  
  def_alter( :update ) do
    allow_only :ADMIN
    optional_fields :parent_topic, :title
  end # === update_it
    

end # === end Topic
