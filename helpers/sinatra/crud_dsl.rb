

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

  def crud_model_options
    raise( ArgumentError, "No model specified." ) if !model
    options.send("crud_#{model_underscore}") 
  end

  def crud_action_options
    return ArgumentError, "No action specified." if !action
    return Struct.new(:require_log_in, 
      :model_class, 
      :model_underscore, 
      :action,
      :path, 
      :path_options,
      :http_method, 
      :success_msg, 
      :error_msg, 
      :redirect,
      :redirect_error,
      :redirect_success).new # if !crud_model_options
    crud_model_options[action]
  end

  def require_log_in?
    !@dont_require_log_in
  end

  def dont_require_log_in
    @dont_require_log_in = true
  end

  [:success_msg, :redirect_success, :error_msg, :redirect_error].each do |meth|
    eval(%~
      def #{meth} txt = nil, &blok
         if !txt && !block_given?
            if @#{meth}.is_a?(Proc)
              instance_eval &@#{meth}
            else
              @#{meth}
            end
         end
         @#{meth} = txt || blok
      end

      def #{meth}? 
         !!@#{meth}
      end
    ~)
  end

  def do_crud model_class, raw_action_name = nil

    action_name = raw_action_name || begin
      if request.get? && request.path =~ /\/edit/
        :edit
      elsif request.get? && request.path =~ /\/new\//
        :new
      elsif request.get?
        :show
      elsif request.post?
        :create
      elsif request.put?
        :update
      elsif request.delete?
        :delete
      else
        raise "Oh, c'mon?!?!"
      end
    end

    action action_name
    model  model_class

    require_log_in! if require_log_in?

    case action

      when :new

        begin
          doc model.new(current_member)
        rescue model::UnauthorizedNew
          not_found
        end

        return render_mab

      when :show
        begin
          doc model.read current_member, clean_room[:id]
        rescue model::NoRecordFound, model::UnauthorizedReader
          not_found
        end
        
        return render_mab

      when :edit
        begin
          doc model.edit current_member, clean_room[:id]
        rescue model::NoRecordFound, model::UnauthorizedEditor
          not_found
        end

        return render_mab

      when :create
        begin
          doc               model.create current_member, clean_room
          flash.success_msg = ( success_msg || 'Successfully saved data.')
          redirect(redirect_success ||  "/#{model_underscore}/#{doc.data._id}/" )

        rescue model::UnauthorizedCreator
          halt(404, "Page Not Found.")

        rescue model::Invalid
          flash.error_msg =  ( error_msg   ||  to_html_list($!.doc.errors) )
          redirect( redirect_error || "/#{model_underscore}/new/"  )
        end

      when :update
        begin
          doc               model.update(current_member, clean_room)
          flash.success_msg = ( success_msg  || "Updated data." )
          redirect( redirect_success || request.path_info )

        rescue model::NoRecordFound, model::UnauthorizedUpdator
          not_found

        rescue model::Invalid
          flash.error_msg = ( error_msg || to_html_list($!.doc.errors) )
          redirect( redirect_error || "/#{model_underscore}/#{$!.doc.data._id}/edit/" )
        end

      when :delete
        begin
          doc               model.delete!( current_member, clean_room[:id])
          flash.success_msg = ( success_msg ||  "Deleted." )
        rescue model::NoRecordFound, model::UnauthorizedDeletor
          flash.success_msg = "Deleted."
        end

        redirect( redirect_success || '/my-work/' )
        
      else
        raise ArgumentError, "Invalid action: #{action_name}"
    end

  end
}

# def CRUD_for(class_obj, &blok) 
# 
#   CRUD_DSL.new(class_obj, &blok)
# 
# end


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
      :redirect,
      :redirect_error,
      :redirect_success
    ]

    ACTIONS = [:new, :show, :edit, :create, :update, :delete].uniq

    attr_reader :options, :model_class, :model_underscore

    def initialize new_model_class, &blok
      @options          = {}
      @model_class      = new_model_class
      @model_underscore = model_class.to_s.underscore

      instance_eval &blok

      options_to_struct

      this_options = @options
      this_model   = @model_underscore
      self.class.instance_eval {
        configure {
          set "crud_#{this_model}", this_options
        }
      }
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

      this_http_method  = options[action_name][:http_method]
      this_path         = options[action_name][:path].inspect
      this_path_options = options[action_name][:path_options].inspect
      this_action       = action_name.inspect
      this_model        = options[action_name][:model_class]

      # This gets tricky. We are implementing a Ruby DSL after all.
      # Anyway, here is an example of what the code below evaluates to:
      #
      # put "/news/1/", *([]) do
      #  do_crud News, :update
      # end
      #
      #

      line = __LINE__
      self.class.instance_eval %~
        
        #{this_http_method} #{this_path}, *(#{this_path_options}) do
          do_crud #{this_model}, #{this_action}  
        end

      ~, __FILE__, line
      
    end

    def new_option k, v
      raise "Programmer error: No @action set." if !action

      if !OPTIONS.include?(k)
        raise ArgumentError, "Unknown options: #{k.inspect}"
      end

      options[action] ||= {}
      options[action][k] = v
    end

    def options_to_struct
      new_options = {}
      options.keys.each do |action|
        action_opts = options[action]
        o_keys = action_opts.keys
        append_keys = OPTIONS - o_keys
        o_vals = o_keys.map {|k| action_opts[k] }
        new_options[action] = Struct.new(*(o_keys+append_keys)).new(*o_vals)
      end
      @options = new_options
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

    def dont_require_log_in
      new_option( :require_log_in, false )
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


