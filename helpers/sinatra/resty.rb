
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
          :index
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
    dev_log_it [action, model_class].inspect # resty.inspect
    
    if resty
      instance, attrs = case action
        when :create, :new
          l = require_log_in! resty.creators.keys
          [nil, l && resty.creators[l]]
        when :update, :edit
          i, l = validate_editor_for_resty_instance model_class, resty.updators.keys
          i ? [i, resty.updators[l]] : [nil, nil]
        when :delete
          i, l = validate_editor_for_resty_instance model_class, resty.deletors
          i ? [i, resty.deletors[l] ] : [nil, nil]
        when :show
          if resty.viewers.keys.include?(:STRANGER)
            [ validate_instance_for_resty(model_class), resty.viewers[ :STRANGER ] ]
          else
            i, l = validate_editor_for_resty_instance model_class, resty.viewers.keys
            [ i, resty.viewers[l] ]
          end
      end # === case action

      describe model_name.to_sym, action 
      return [instance, attrs]
    end # === if level

    pass
    nil
  end # === def

  def validate_editor_for_resty_instance(model_class, resty_roles )
    require_log_in!
    instance = validate_instance_for_resty(model_class)
    member_levels = resty_roles.select { |l| !instance.respond_to?(l) }
    i_meths = resty_roles - member_levels
    in_assoc = i_meths.detect { |i| instance.send(i).include?(current_member) }
    level = member_levels.detect {|l| current_member.has_power_of?(l) }
    return [instance, in_assoc || level ]  if in_assoc || level
    not_found 
  end # === def

  def validate_instance_for_resty(model_class)
    instance = model_class[:id=>clean_room[:id]]
    not_found if !instance
    instance
  end



} # === helpers
