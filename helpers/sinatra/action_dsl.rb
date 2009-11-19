
def allow(class_obj, &blok) 

  ActionDSL.new(self, class_obj, &blok)

end

get '/action_dsl/' do
  ActionDSL::ACTIONS.inject('') { |m,a|
    m += a.inspect + '<br /><pre>' + options.send("news_#{a}").inspect + '</pre>'
    m
  }
  
  
end

configure do 

  class ActionDSL_Options

    private
    attr_accessor :options

    public 

    def initialize action_dsl_instance, action, *args, &blok

      path_or_regex = args.first
      
      self.options = { :require_log_in => true,
        :model_class      => action_dsl_instance.model_class,
        :model_underscore => action_dsl_instance.model_underscore,
        :action           => action
      }

      method_path = case options[:action]
        when :new
          [ :get, "/#{options[:model_underscore]}/new/" ]
        when :show
          [ :get, "/#{options[:model_underscore]}/:id/" ]
        when :edit
          [ :get, "/#{options[:model_underscore]}/:id/edit/" ]
        when :create
          [ :post, "/#{options[:model_underscore]}/" ]
        when :update
          [ :put, "/#{options[:model_underscore]}/:id/" ]
        when :delete 
          [ :delete, "/#{options[:model_underscore]}/:id/" ]
        else
          raise ArgumentError, "Invalid action: #{options[:action].inspect}"
      end

      options[:http_method] = method_path.first
      options[:path]  = method_path.last
      options[:path] = path_or_regex.inspect if path_or_regex

      instance_eval &blok if block_given?
      options 
    end
    
    def manipulator_name
      case o(:action)
        when :new
          :new
        when :create
          :creator
        when :updator
          :updator
        when :edit
          :editor
        when :show
          :reader
        when :delete
          :deletor
      end
    end

    def path s=nil
      self.options[:path] = s
    end

    def error_msg msg = nil, &blok
      options[__method_name__] = msg || blok
    end

    def success_msg msg=nil, &blok
      options[__method_name__] = msg || blok
    end

    def error(*errs, &blok)
      options[:rescue] = {}
      errs.each { |e|
        case e
          when Symbol
            e_class = case e
              when :no_record
                o(:model_class).const_get((e.to_s + '_found').camelize)
              when :unauthorized
                o(:model_class).const_get((e.to_s + '_' + manipulator_name.to_s).camelize)
              else
                o(:model_class).const_get(e.to_s.camelize)
            end
            e_class = 
            options[:rescue][e_class] = blok
          when String
            raise ArgumentError, "Strings are not allowed here: #{e.inspect}"
          else
            options[:rescue][e] = blok
        end
      }
    end

    def redirect path=nil, &blok
      options[:redirect] = path || blok
    end

    def o raw_key
      key = raw_key.to_sym
      if !options.has_key?(key)
        raise ArgumentError, ":key not found: #{raw_key.inspect}" 
      end
      options[key]
    end

    def as_hash
      options
    end

  end # === ActionOptionsDSL

  class ActionDSL

    ACTIONS = [:new, :show, :edit, :create, :update, :delete].uniq

    [:model_class, :model_underscore].each { |a|
      private
      attr_writer a

      public
      attr_reader a
    }

    public

    def initialize app_scope, model_class, &blok
      @app_scope = app_scope
      self.model_class = model_class
      self.model_underscore = model_class.to_s.underscore

      instance_eval &blok
    end

    ACTIONS.each { |a|
      eval %~
        def #{a} *args, &blok
          create_action #{a.inspect}, *args, &blok
        end
      ~
    }

    def create_action action_name, *path_and_more, &blok

      o                    = ActionDSL_Options.new(self, action_name, *path_and_more, &blok )
      model_action_options = [self.model_underscore, action_name].join('_')

      configure {
        set model_action_options, o.as_hash
      }
      
      @app_scope.send( o.o(:http_method) ,  o.o(:path) ) do
        describe o.o(:model_class), o.o(:action)
        [o.o(:model_class), o.o(:action)].inspect
      end
      
    end


  end # === class ActionDSL 
end # === configure

