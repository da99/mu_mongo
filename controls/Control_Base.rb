
module Control_Base

  # ======== INSTANCE stuff ======== 
  
  include Rack::Utils
  attr_accessor :app, :env, :request, :response, :params
  attr_reader   :controller, :controller_name, :action_name 
  
  def initialize(new_env)
    @app      = self
    @env      = new_env
    @env      = new_env
    @request  = Rack::Request.new(@env)
    @response = Rack::Response.new
    @env['bunny.app'] = self
  end

  def clean_params 
    @clean_params ||= begin
                        data = {}
                        request.params.each { |k,v| 
                          data[k] = v ? v.strip : nil
                          if data[k].empty?
                            data[k] = nil
                          end
                        }
                        data
                      end
  end

  def controller= class_obj
    @controller = class_obj
    @controller_name = class_obj.to_s.sub('_Bunny', '').to_sym
  end 

  def action_name= new_name
    @action_name = new_name.to_s.strip.to_sym
  end
  
  def environment 
    ENV['RACK_ENV']
  end

  def redirect! *args
    render_text_plain ''
    response.redirect( *args )
    raise Good_Bunny::Redirect
  end

  def not_found! body
    error! body, 404
  end

  # Halt processing and return the error status provided.
  def error!(body, code = 500)
    response.status = code
    response.body   = body unless body.nil?
    raise Bad_Bunny.const_get("Error_#{code}")
  end

	def render_application_xml txt
    response.body = txt
    set_header 'Content-Type', 'application/xml; charset=utf-8'
    set_header 'Accept-Charset',   'utf-8'
    set_header 'Cache-Control',    'no-cache'
    set_header 'Pragma',           'no-cache'
	end

  def render_text_plain txt
    response.body = txt
    set_header 'Content-Type', 'text/plain; charset=utf-8'
    set_header 'Accept-Charset',   'utf-8'
    set_header 'Cache-Control',    'no-cache'
    set_header 'Pragma',           'no-cache'
  end

  def render_text_html txt
    response.body = txt
    set_header 'Content-Type',     'text/html; charset = utf-8'
    set_header 'Accept-Charset',   'utf-8'
    set_header 'Cache-Control',    'no-cache'
    set_header 'Pragma',           'no-cache'
  end


  def render_html_template vals = {}
    file_name        = "#{controller_name}_#{action_name}"
    template_content = begin
												 File.read(File.expand_path('templates/English/mustache/' + file_name.to_s + '.html'))
											 rescue Errno::ENOENT
												 begin
													 Mab_In_Disguise.mab_to_mustache( 'English', file_name )
												 rescue Errno::ENOENT
													 nil
												 end
											 end
    
    if not template_content
      raise "Something went wrong. No template content found for: #{file_name.inspect}"
    end

    require "views/#{file_name}.rb"
    view_class = Object.const_get(file_name)
    view_class.raise_on_context_miss = true
    html       = view_class.new(self, vals).render( template_content )
    
    render_text_html(html)
  end

	def render_xml_template
    file_name        = "#{controller_name}_#{action_name}".to_sym
    template_content = begin
												 File.read(File.expand_path('templates/English/mustache/' + file_name.to_s + '.html'))
											 rescue Errno::ENOENT
												 begin
													 Xml_In_Disguise.xml_to_mustache( 'English', file_name )
												 rescue Errno::ENOENT
													 nil
												 end
											 end
    
    if not template_content
      raise "Something went wrong. No template content found for: #{file_name.inspect}"
    end

    require "views/#{file_name}.rb"
    view_class = Object.const_get(file_name)
    view_class.raise_on_context_miss = true
    xml       = view_class.new(self).render( template_content )
    
		render_application_xml xml
	end
   
  def env_key raw_find_key
    find_key = raw_find_key.to_s.strip
    if @env.has_key?(find_key)
      return @env[find_key]
    end
    raise ArgumentError, "Key not found: #{find_key.inspect}"
  end

  def set_env_key find_key, new_value
    env_key find_key
    @env[find_key] = new_value
  end

  # Returns an array of acceptable media types for the response
  def allowed_mime_types
    @allowed_mime_types ||= @env['HTTP_ACCEPT'].to_s.split(',').map { |a| a.strip }
  end

  def ssl?
    (@env['HTTP_X_FORWARDED_PROTO'] || @env['rack.url_scheme']) === 'https'
  end
   
  def valid_header_keys
    @valid_header_keys ||= (@response.header.keys + [ 'Accept-Charset', 
    'Content-Disposition', 
    'Content-Type', 
    'Content-Length',
    'Cache-Control',
    'Pragma'
    ]).uniq
  end

  def add_valid_header_key raw_key
    new_key = raw_key.to_s.strip
    @valid_header_keys = (valid_header_keys + [raw_key]).uniq
    new_key
  end

  def set_header key, raw_val 
    if !valid_header_keys.include?(key)
      raise ArgumentError, "Invalid header key: #{key.inspect}"
    end
    @response.header[key] = raw_val.to_s
  end

  # Set the Content-Type of the response body given a media type or file
  # extension.
  def set_content_type(mime_type, params={})
    if params.any?
      params = params.collect { |kv| "%s=%s" % kv }.join(', ')
      set_header 'Content-Type', [mime_type, params].join(";")
    else
      set_header 'Content-Type', mime_type
    end
  end

  # Set the Content-Disposition to "attachment" with the specified filename,
  # instructing the user agents to prompt to save.
  def set_attachment(filename)
    set_header 'Content-Disposition', 'attachment; filename="%s"' % File.basename(filename)
  end  
  
  # ------------------------------------------------------------------------------------
  private # ----------------------------------------------------------------------------
  # ------------------------------------------------------------------------------------

  def respond_to_request? ctrl_class

    http_meth = env_key(:REQUEST_METHOD).to_s
    pieces    = env_key(:PATH_INFO).gsub(/\A\/|\/\Z/, '').split('/').map { |sub|
      sub.gsub(/[^a-zA-Z0-9_]/, '_') 
    }

    ctrlr, a_name, args = if env_key(:PATH_INFO) === '/'
      
      [ Bunny_DNA.controllers.first,  
        'list',
        []
      ]
      
    else
      
      mic_class_name = pieces.shift.
                        split('_').
                        map(&:capitalize).
                        join('_') + 
                        mic_class_name_suffix

      if Object.const_defined?(mic_class_name)
        
        mic_class   = Object.const_get(mic_class_name)
        action_name = [ http_meth , pieces.first ].compact.join('_')
        meth        = pieces.first ? pieces.first.to_s.gsub(/[^a-zA-Z0-9_]/, '_') : 'NONE'
      
        
        if pieces.empty? && 
           request.get? &&
           mic_class.public_instance_methods.include?('GET_list')
          
           [ mic_class, 'list', [] ]
          
        elsif mic_class.public_instance_methods.include?(action_name) &&
              mic_class.instance_method(action_name).arity === (pieces.empty? ? 1 : pieces.size )

          pieces.shift
          [ mic_class, meth, pieces ]
          
        elsif mic_class.public_instance_methods.include?(http_meth) &&
              mic_class.instance_method(http_meth).arity === (pieces.size + 1)

          [ mic_class, http_meth, pieces ]
          
        end

      else
        []
      end

    end   
    
    if ctrlr && a_name && args
      self.controller  = ctrlr
      self.action_name = a_name
      controller.new.send("#{http_meth}_#{action_name}", self, *args)
      return true
    end
      
    raise Bad_Bunny::HTTP_404, "Unable to process request: #{response.request_method} #{response.path}"
  end

end # === Control_Base
