
def resty(model_name_sym, &blok)
  Resty.new(model_name_sym, &blok)
end


helpers {

  def validate_as_resty!(model_name= nil)
    
    model_name = if !model_name
      clean_room[:model]
    else
      model_name.to_s
    end

    model_name = model_name.underscore.camelize if model_name
    
    model_class = if model_name
      model_name_camel = model_name.camelize
      Object.const_defined?( model_name_camel ) && Object.const_get(model_name_camel)
    end

    if !model_class
      pass
      return nil
    end

    action = if request.get? 
      case request.fullpath 
        when /\/edit\/?$/
          :edit
        when /\/new\/?$/
          :new
        when /\/[0-9]+\/?$/
          :show
        else
          :list
      end
    elsif request.post?
      :create
    elsif request.put?
      :update
    elsif request.delete?
      :delete
    else
      nil
    end

    if !action
      pass
      return nil
    end
    
    resty = Resty.find(action, model_class)
    # dev_log_it resty.inspect
    
    if resty
      instance = case action
        when :create, :new
          require_log_in! resty.creators.keys

        when :update, :edit
          validate_editor_for_resty_instance model_class, resty.updators.keys

        when :delete
          validate_editor_for_resty_instance model_class, resty.deletors
          
        else
          unless resty.viewers.keys.include?(:STRANGER)
            validate_editor_for_resty_instance model_class, resty.viewers.keys
          end
      end # === case action

      describe model_name.to_sym, action 
      return instance
    end # === if level

    pass
    nil
  end

} # === helpers
