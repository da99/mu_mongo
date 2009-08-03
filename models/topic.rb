class Topic < Sequel::Model

  # ==== CONSTANTS =====================================================
  
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  
  
  # ==== HOOKS =========================================================


  # ==== CLASS METHODS =================================================


  # ==== INSTANCE METHODS ==============================================


  def self.create_it( raw_params, editor )
    return nil unless editor.has_permission_level?(:ADMIN)
    params = filter_params( raw_params, [:parent_topic, :title] )
    
    new_record = new
    new_record.set params
    new_record.save
    
  end # === create_it
  
  def update_it( raw_params, editor )
    return nil unless editor.has_permission_level?(:ADMIN)
    params = self.class.filter_params( raw_params, [:parent_topic, :title] )
    
    update params
  end # === update_it
  


  

end # === end Topic
