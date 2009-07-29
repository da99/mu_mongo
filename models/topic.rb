class Topic < Sequel::Model

  # ==== CONSTANTS =====================================================
  
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  
  
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

  def find_validation_errors
  end # === def find_validation_errors
  
  def columns_for_editor( params, editor )
    params.keys
  end  
  
  def alter_it( action, raw_params, editor = nil)
    params = {}
    columns_for_editor(raw_params, editor).each { |col|
      params[col] = raw_params[col]
    }
    @alter_errors = []
    
    send( "#{action}_with_editor", params, editor )
    
    save_it(params)
    
  end # === def alter_with_editor
  
  def create_it( *args )
    
  end
  
  def save_it( params )

    return if params.empty?
    if !self.errors.empty?
      raise Invalid 
    end
    params.each { |k,v| 
      send("#{k}=", Wash.plaintext(v)
    } 
    find_validation_errors
    save
  end
  

end # === end Topic
