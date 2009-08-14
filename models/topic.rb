class Topic < Sequel::Model

  # ==== CONSTANTS =====================================================
  
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  
  
  # ==== HOOKS =========================================================


  # ==== CLASS METHODS =================================================

  def self.create_it!( raw_params )    
    new_record = new
    new_record.set_title! raw_params
    new_record.set_if_key_exists( raw_params, [:parent_topic] )
    new_record.save_it!( raw_params )
    
  end # === create_it
  

  # ==== INSTANCE METHODS ==============================================
  
  def update_it!( raw_params )
    set_if_key_exists( raw_params, [:parent_topic, :title] )
    save_it! raw_params
  end # === update_it
  

  def has_permission?( action, raw_params )
    case action
      when :create, :update, :delete
        raw_params[:EDITOR] && raw_params[:EDITOR].admin?
      else
        false
    end
  end
  

end # === end Topic
