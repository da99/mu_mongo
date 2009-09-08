# ========================================
# Override :changes_from_editor. Setting @current_editor
# and @editable_by_editor (Array of fields). Then call :super 
# without any arguments.
# Set either @current_editor to nil if not authorized.
# ========================================
module EditorGuard

    class UnauthorizedEditor < StandardError; end
    
    def self.included(target_class)
    end
    
  def changes_from_editor( vals_hash,  mem = nil)
  
    if !@current_editor
        raise UnauthorizedEditor, mem.inspect
    end
    
    if !@editable_by_editor 
        raise "Programmer Error: Fields for editor not set."
    end

    vals_hash.each do |k,v|
        # We use send() instead of self[]= because values 
        # might be an attribute from attr_accessor/    
        self.send("#{k}=", v)  if self.respond_to?("#{k}=") &&  @editable_by_editor .include?(k.to_sym)
    end
    
  end # === changes_from_editor
  
end # === module
