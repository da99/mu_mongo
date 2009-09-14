class Resty
  
  attr_accessor :model_name
  attr_accessor :model_class
  attr_accessor :viewers
  attr_accessor :creators
  attr_accessor :updators
  attr_accessor :deletors
  
  VALID_VIEW_ACTIONS = [:index, :show]

  class << self
    def validate_new_model_name(model_name)
      @model_names ||= []
      if @model_names.include?(model_name)
        raise ArgumentError, "#{model_name} already used."
      end
    end
    def add_to_children(obj)
      self.children << obj
    end
    def children
      @children ||= []
    end
    def find(action, model_class)
      resty = children.detect { |r|
        r.model_class == model_class 
      }
      if resty 
        return resty if resty.viewers.values.flatten.include?(action)
        return resty if [:create, :new].include?(action) && !resty.creators.empty?
        return resty if [:update, :edit].include?(action) && !resty.updators.empty?
        return resty if :delete == action && !resty.deletors.empty?
      end
      nil
    end
  end
  
  def initialize(model_name, &blok)
    self.model_name = model_name.to_s
    self.class.validate_new_model_name(self.model_name)
    self.model_class = Object.const_get(self.model_name.camelize)
    [:viewers, :creators, :updators].each {|a|
      send("#{a}=", {} )
    }
    self.deletors = []
    instance_eval &blok
    self.class.add_to_children self
  end

  def __normalize_list__(arr)
    arr.flatten.uniq.compact
  end
  
  def viewer(level, raw_actions = [:show])
    actions = __normalize_list__(raw_actions)
    invalid_actions = actions - VALID_VIEW_ACTIONS
    if !invalid_actions.empty?
      raise ArgumentError, "Invalid viewer actions: #{invalid_actions.inspect}"
    end
    self.viewers[level] = actions
  end

  def creator(level, *raw_cols)
    cols = __normalize_list__(raw_cols)
    self.creators[level] = cols
  end
  
  def updator(level, *raw_cols)
    cols = __normalize_list__(raw_cols)
    self.updators[level] = cols
  end
  
  def creator_and_updator(*args)
    creator(*args)
    updator(*args)
  end
  
  def creator_and_updator_and_deletor(*args)
    creator_and_updator *args
    deletor args.first
  end
  alias_method :c_u_d, :creator_and_updator_and_deletor

  def deletor(level)
    if self.deletors.include?(level)
      raise ArgumentError, "#{level.inspect} already included as a deletor."
    end
    self.deletors << level
  end

end # === Resty
