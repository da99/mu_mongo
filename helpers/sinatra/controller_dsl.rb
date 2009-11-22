def controller name, &blok
  ControllerDSL.new(name, &blok)
end

configure do

  class ControllerDSL

    private
      attr_writer :name
    public
      attr_reader :name

    def initialize name, &blok
      self.name = name
      instance_eval &blok
    end

    [:get, :put, :post, :delete].each { |action|
      eval %~
        def #{action} *args, &blok
          new_action #{action.inspect}, args, blok
        end
      ~
    }

    def new_action action_name, args, blok
      option_name = "__#{action_name}_#{blok.object_id}__".to_sym

      set option_name, blok

      self.class.instance_eval %~
        #{action_name}(*(#{args.inspect})) do
          controller #{name}
          instance_eval &(options.#{option_name})
        end
      ~
    end

  end # === class ControllerDSL

end # === configure
