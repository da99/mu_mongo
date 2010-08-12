
class  Config_Switches

  attr_reader :store, :ask, :put, :get

  def initialize &blok
    @store = {}
    
    accessor = Class.new {
      attr_reader :config
      
      def initialize new_config
        @config = new_config
      end
    }
    
    %w{ask put get}.each { |prop|
      eval %~
        @#{prop} = accessor.new(self)
      ~
    }

    if block_given?
      instance_eval &blok
    end
  end
    
  def as_hash *keys
    keys.inject({}) { |memo, k|
      memo[k] = get.send(k)
      memo
    }
  end

  def put &configuration
    if block_given?
      @put.instance_eval &configuration
    end
    @put
  end

  def on
    true
  end
  
  def off
    false
  end
  
  def strings *args
    args.each { |field|
      eval %~
        def get.#{field}
          config.store[:#{field}]
        end

        def put.#{field} val
          config.store[:#{field}] = val
        end
      
        def ask.#{field}?
          !!config.get.#{field}
        end
      ~
    }
  end
  alias_method :string, :strings

  def arrays *args
    args.each { |field|
      eval %~
        def get.#{field}
          config.store[:#{field}] ||= []
        end
        
        def put.#{field} *args
          config.store[:#{field}] = if args.is_a?(Array) && args.first.is_a?(Array) &&args.size == 1
                                      args.first
                                    else
                                      args
                                    end
        end

        def ask.#{field}?
          !config.get.#{field}.empty?
        end
      ~
    }
  end
  alias_method :array, :arrays

  def hashes *args
    args.each { |field|
      eval %~
        def get.#{field}
          config.store[:#{field}] || {}
        end

        def put.#{field} hsh
          config.store[:#{field}] = hsh
        end

        def ask.#{field}?
          !config.get.#{field}.empty?
        end
      ~
    }
  end
  alias_method :hash, :hashes

  def string_or_block *args
    args.each { |name|
      eval %~
        def get.#{name}
          config.store[:#{name}] || []
        end
        
        def put.#{name} str = nil, &blok
          config.store[:#{name}] = [str, blok]
        end
        
        def ask.#{name}?
          !config.get.#{name}.empty?
        end
      ~
    }
  end

  def switch name, default = nil
    if default.nil?
      default = off
    end

    eval %~
      def get.#{name}_up
        !#{default}
      end
    
      def get.#{name}_down
        #{default}
      end
    
      def get.#{name}
        config.store.has_key?(:#{name}) ?
          config.store[:#{name}] :
          #{name}_down
      end
    
      def put.#{name}
        config.store[:#{name}] = config.get.#{name}_up
      end
        
      def ask.#{name}?
        !!config.get.#{name}
      end
    ~
  end

end # === class Config_Switches
