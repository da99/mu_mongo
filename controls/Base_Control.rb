require 'views/Base_View'

module Base_Control

  # ======== INSTANCE stuff ======== 
  
  include Rack::Utils
  attr_accessor :app, :env, :request, :response, :params
  
  def initialize(new_env)
    @app      = self
    @env      = new_env
    @request  = Rack::Request.new(@env)
    @response = Rack::Response.new
  end
  
  def secure?
    (@env['HTTP_X_FORWARDED_PROTO'] || @env['rack.url_scheme']) == 'https'
  end

  # NOTE:
  # Returns original Hash from Rack::Request, without 
  # symbolized keys.
  #
  # From: Sinatra
  #   View original:
  #   http://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb
  def params
    @orig_params ||= begin
                       request.POST
                     rescue EOFError, Errno::ESPIPE
                       {}
                     end
  end

  def clean_room
    @clean_params ||= begin
                        params.symbolize_keys
                      end
  end
  
  def control
    self
  end

  def control_name
    @control_name ||= self.class.to_s.sub('_Bunny', '').to_sym
  end

  def action_name
    @action_name ||= env['the.app.meta'][:action_name]
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

  def lang
    'English'
  end
  
  def environment 
    ENV['RACK_ENV']
  end

  def redirect! *args
    render_text_plain ''
    response.redirect( *args )
    raise The_App::Redirect
  end

  def not_found! body
    error! body, 404
  end

  # Halt processing and return the error status provided.
  def error!(body, code = 500)
    response.status = code
    response.body   = body unless body.nil?
    raise The_App.const_get("HTTP_#{code}")
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

  def process_mustache ext = 'html'
    file_name = "#{control_name}_#{action_name}"
    template_content = begin
												 File.read("templates/#{lang}/mustache/#{file_name}.#{ext}")
											 rescue Errno::ENOENT
												 begin
													 disguise = if ext == 'html'
                             'Mab'
                           else
                            ext.capitalize
                           end
                           require( "middleware/#{disguise}_In_Disguise"  )
                           disguise_class = Object.const_get( "#{disguise}_In_Disguise" )
                           disguise_class.compile( "templates/#{lang}/#{disguise.downcase}/#{file_name}.rb" ) 
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
    html       = view_class.new(self).render( template_content )
  end

  def render_html_template
    render_text_html(
      process_mustache
    )
  end

	def render_xml_template
		render_application_xml(
      process_mustache('xml')
    )
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

  # === Session-related helpers ===

  def session
    env['rack.session'] ||= {}
  end
  
  def flash_msg
    env['flash.msg']
  end

  def require_log_in! *perm_levels

    return true if perm_levels.empty? && logged_in?

    if not logged_in? 
      if request.get?
        session[:return_page] = request.fullpath
        redirect!('/log-in/')
      else
        render_error_msg( 200, "Not logged in. Log-in first and try again." )
      end
    end

    if !current_member.any_of_these_powers?(perm_levels)
      error(404, "Not found.")
    end
 
    true
  end 
  
  def log_out!
    return_page = session.delete(:return_page)
    session.clear
    session[:return_page] = return_page
  end 
  
  def logged_in?
    session[:member_id] && current_member && !current_member.new?
  end # === def      

  def current_member=(mem)
    raise "CURRENT MEMBER ALREADY SET" if logged_in?
    session[:member_id] = mem.data._id
  end    

  def current_member
    return nil if !session[:member_id]
    @current_member ||= Member.by_id( session[:member_id] )
  end # === def
  
  
  # ------------------------------------------------------------------------------------
  private # ----------------------------------------------------------------------------
  # ------------------------------------------------------------------------------------

  def respond_to_request? ctrl_class

    http_meth = env_key(:REQUEST_METHOD).to_s
    pieces    = env_key(:PATH_INFO).gsub(/\A\/|\/\Z/, '').split('/').map { |sub|
      sub.gsub(/[^a-zA-Z0-9_]/, '_') 
    }

    ctrlr, a_name, args = if env_key(:PATH_INFO) === '/'
      
      [ Bunny_DNA.controls.first,  
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
      self.control  = ctrlr
      self.action_name = a_name
      control.new.send("#{http_meth}_#{action_name}", self, *args)
      return true
    end
      
    raise The_App::HTTP_404, "Unable to process request: #{response.request_method} #{response.path}"
  end

end # === Base_Control
