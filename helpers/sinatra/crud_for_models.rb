

helpers {

  def choose *args
    args.detect { |a|
      case a
        when Proc
          instance_eval &a
        else
          a
      end
    }
  end

  def do_crud action_name, raw_options
    o_keys = raw_options.keys
    o_vals = o_keys.map { |k| raw_options[k] }
    o      = Struct.new(*o_keys).new(*o_vals)

    describe o.model_class, action_name


    #return [action_name, raw_options].inspect
    require_log_in! if o.require_log_in!

    case action_name

      when :new
        begin
          model_class.new(current_member)
        rescue model_class::UnauthorizedNew
          pass
        end

        return render_mab

      when :show
        begin
          @doc = model_class.read current_member, clean_room[:id]
        rescue model_class::NoRecordFound, model_class::UnauthorizedReader
          pass
        end
        
        return render_mab

      when :edit
        begin
          @doc = model_class.edit current_member, clean_room[:id]
        rescue model_class::NoRecordFound, model_class::UnauthorizedEditor
          pass
        end

      when :create
        begin
          @doc              = model_class.create current_member, clean_room
          flash.success_msg = choose( o.success_msg, 'Successfully saved data.')
          redirect          choose(o.redirect_success, "/#{model_underscore}/#{@doc._id}/" )

        rescue model_class::UnauthorizedCreator
          pass

        rescue model_class::Invalid
          flash.error_msg  choose( o.error_msg,      to_html_lists($!.doc.errors) )
          redirect         choose( o.redirect_error, "/#{model_underscore}/new/"  )
        end

      when :update
        begin
          @doc              = model_class.update(current_member, clean_room)
          flash.success_msg = choose( o.success_msg,    "Updated data." )
          redirect          choose( o.redirect_success, request.path_info )

        rescue model_class::NoRecordFound, model_class::UnauthorizedUpdator
          pass

        rescue model_class::Invalid
          flash.error_msg = choose( o.error_msg, to_html_list($!.doc.errors) )
          redirect        choose( o.redirect_error, "/#{model_underscore}/#{$!.doc._id}/edit/" )
        end

      when :delete
        begin
          @doc              = model_class.delete!( current_member, clean_room[:id])
          flash.success_msg = choose( o.success_msg, "Deleted." )

        rescue model_class::NoRecordFound, model_class::UnauthorizedDeletor
          flash.success_msg = "Deleted."
        end

        redirect choose( o.redirect_success, '/my-work/' )
        

      else
        raise ArgumentError, "Invalid action: #{action_name}"
    end

  end
}

def CRUD_for(class_obj, &blok) 

  CRUD_DSL.new(class_obj, &blok)

end


configure do 

  class CRUD_DSL

    # === CONSTANTS ===================================

    OPTIONS =  [ 
      :require_log_in, 
      :model_class, 
      :model_underscore, 
      :action,
      :path, 
      :path_options,
      :http_method, 
      :success_msg, 
      :error_msg, 
      :redirect 
    ]

    ACTIONS = [:new, :show, :edit, :create, :update, :delete].uniq

    attr_reader :options, :model_class, :model_underscore

    def initialize new_model_class, &blok
      @options          = {}
      @model_class      = new_model_class
      @model_underscore = model_class.to_s.underscore
      @allow_action_create = true
      instance_eval &blok
    end

    ACTIONS.each { |a| 
      eval %~
        def #{a} *args, &blok
          new_action #{a.inspect}, *args, &blok
        end
      ~
    }

    def validate_action action
      if !ACTIONS.include?(action)
        raise ArgumentError, "Invalid action: #{action.inspect}"
      end
      true
    end

    private # ===========================================

    attr_reader :action

    def new_action action_name, new_path=nil, *path_options, &blok

      validate_action action_name
      @action = action_name

      new_option :http_method,    default_http_method
      new_option :path,           new_path || path
      new_option :path_options,   path_options
      new_option :require_log_in, true
      new_option :model_class,    model_class
      new_option :model_underscore, model_underscore

      instance_eval &blok if block_given?

      this_options = options[action_name]
      this_action  = action_name

      self.class.instance_eval {
        self.send this_options[:http_method], this_options[:path], *this_options[:path_options] do
          self.do_crud this_action, this_options
        end
      }
      
    end

    def new_option k, v
      raise "Programmer error: No @action set." if !action

      if !OPTIONS.include?(k)
        raise ArgumentError, "Unknown options: #{k.inspect}"
      end

      options[action] ||= {}
      options[action][k] = v
    end

    def default_http_method 
      case action
        when :new;    :get
        when :show;   :get
        when :edit;   :get
        when :create; :post
        when :update; :put
        when :delete; :delete
      end
    end

    def default_path
      case action
        when :new;      "/#{model_underscore}/new/"
        when :show;     "/#{model_underscore}/:id/"
        when :edit;     "/#{model_underscore}/:id/edit/"
        when :create;   "/#{model_underscore}/"
        when :update;   "/#{model_underscore}/:id/"
        when :delete;   "/#{model_underscore}/:id/"
      end
    end

    def path s=nil
      new_option( __method_name__, s || default_path )
    end

    def error_msg msg = nil, &blok
      new_option( __method_name__, msg || blok)
    end

    def success_msg msg=nil, &blok
      new_option( __method_name__, msg || blok)
    end

    def redirect path=nil, &blok
      new_option( __method_name__, path || blok)
    end

    def manipulator_name action_name
      case action_name
        when :new;     :new
        when :create;  :creator
        when :updator; :updator
        when :edit;    :editor
        when :show;    :reader
        when :delete;  :deletor
      end
    end

  end # === class CRUD_DSL 

end # === configure


