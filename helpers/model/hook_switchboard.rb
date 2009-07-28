module HookSwitchboard

    def self.included(target_class)
        target_class.extend ClassMethods
    end
    
  module ClassMethods
      def hook_for( *args, &new_proc)
        HookSwitchboardCache.hook_for(*args, &new_proc)
      end  
  end # === module

  def hook_it(action_name)
    if [:create, :update].include?(action_name)
        HookSwitchboardCache.do_this( "before_validate".to_sym, self )
        validate_it!
        HookSwitchboardCache.do_this( "after_validate".to_sym, self )
    end
    HookSwitchboardCache.do_this( "before_#{action_name}".to_sym, self )
    yield
    HookSwitchboardCache.do_this( "after_#{action_name}".to_sym, self )
  end  

end # === module
  
class HookSwitchboardCache

  VALID_PREFIXES = ['before', 'after']
  VALID_SUFFIXES = ['update', 'destroy', 'create', 'validate', 'save']
  
  class InvalidClassName < RuntimeError; end

  def self.__switch__
    @switchboard ||= {}
  end

  def dev_log(msg)
    raise "take HookSwitches out"
  end

  def self.hook_for( raw_model_class, action_as_sym, &new_proc )

    model_class_name_as_sym = if raw_model_class.is_a?(Symbol)
      raw_model_class
    else
      raw_model_class.name.to_sym
    end

    # validation action name
    action_as_string = action_as_sym.to_s
    action_parts = action_as_string.split('_')
    action_prefix = action_parts.shift
    action_suffix = action_parts.join('_')
    action_parts = nil

    unless VALID_PREFIXES.include?(action_prefix)
      raise ArgumentError, "Only 'before' or 'after' can be used as a prefix for action: #{action_as_sym.inspect}"
    end

    unless VALID_SUFFIXES.include?(action_suffix)
      raise ArgumentError, "Invalid action suffix: #{action_as_sym.inspect}"
    end

    # Add values to switchboard.
    __switch__[model_class_name_as_sym] ||= {}
    __switch__[model_class_name_as_sym][action_as_sym] ||= []
    __switch__[model_class_name_as_sym][action_as_sym] << new_proc

    nil
  end # === function: add_hook


  def self.do_this( action_as_sym, item)
    # Validate model names and cache results so we don't have to do it next time..
    @model_names_validated ||= begin
        __switch__.keys.each { |sym_name| 
          if sym_name != :ALL && !Object.const_defined?(sym_name)
            raise InvalidClassName, "Invalid model name: #{sym_name.inspect}" 
          end
        }    
    end
    
    hooks_for_all = __switch__[:ALL]
    if hooks_for_all && hooks_for_all[action_as_sym]
        hooks_for_all[action_as_sym].each { |stuff|
            dev_log "Executing hook: #{:ALL} #{action_as_sym.inspect}"
            stuff.call(item)
            dev_log "Finished executing hook: #{:ALL} #{action_as_sym.inspect}"
        }
    end
    
    hooks = __switch__[item.class.name.to_sym]
    if hooks && hooks[action_as_sym]
      hooks[action_as_sym].each { |stuff|
        dev_log "Executing hook: #{item.class.name.to_sym} #{action_as_sym.inspect}"
        stuff.call(item)
        dev_log "Finished executing hook: #{item.class.name.to_sym} #{action_as_sym.inspect}"
      }
    end

  end # def self.do_this


end # === class: HookSwitchboardCache

