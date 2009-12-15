
class Bunny_Mating

  attr_accessor :env, :request, :response, :params

  include Rack::Utils
  
  def call!(new_env)
    @env      = new_env
    @request  = Rack::Request.new(@env)
    @response = Rack::Response.new

   # return [200, {'Content-Type' => 'text/plain' }, 'zzzzz' ] 
     
    begin
      
      run_the_request 
      
    rescue Bad_Bunny::Redirect
      
    rescue Bad_Bunny::HTTP_404
      
      @env['little.microphone.error'] = $!
      @response.status = 404
      @response.body   = '<h1>Not Found</h1>'
      
    rescue Object
      if The_Bunny_Farm.development? 
        raise $!
      end
      @env['little.microphone.error'] = $!
      error! '<h1>Unknown Error.</h1>'
      
    end

    status, header, body = @response.finish

    # From The Sinatra Framework:
    #   Never produce a body on HEAD requests. Do retain the Content-Length
    #   unless it's "0", in which case we assume it was calculated erroneously
    #   for a manual HEAD response and remove it entirely.
    if @env['REQUEST_METHOD'] == 'HEAD'
      body = []
      header.delete('Content-Length') if header['Content-Length'] == '0'
    end

    [status, header, body]
  end

  The_Bunny_Farm::Options::ENVIRONS.each { |envir|
    %~
      def #{envir}?
        ENV['RACK_ENV'] == "#{envir}"
      end
    ~
  }
  
  def redirect! *args
    render_text_plain ''
    response.redirect *args
    raise Bad_Bunny::Redirect
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

  def render_text_plain txt
    response.body = txt
    response.set_header 'Content-Type', 'text/plain'
  end

  def render_text_html txt
    response.body = txt
    response.set_header 'Content-Type', 'text/html'
  end
  
  # ------------------------------------------------------------------------------------
  private # ----------------------------------------------------------------------------
  # ------------------------------------------------------------------------------------

  def mic_classes
    [Hello_Bunny, Inspect_Bunny]
  end
  
  def mic_class_name_suffix
    '_Bunny'
  end

	def mic_class_names
		@mic_class_names ||= mic_classes.map(&:to_s)
	end

  def run_the_request 
    
    http_meth = request.env_key(:REQUEST_METHOD).to_s
    pieces    = request.env_key(:PATH_INFO).split('/')

    pieces.shift if pieces.first === ''

    if pieces.empty?
      mic_classes.first.new.send(http_meth + '_list', self)
      return true
    end

    mic_class_name = pieces.first.
                      gsub(/[^a-zA-Z0-9_]/, '_').
                      split('_').map(&:capitalize).
                      join('_') + 
                      mic_class_name_suffix

    if mic_class_names.include?(mic_class_name)
      pieces.shift

      mic_class = Object.const_get(mic_class_name)

      if pieces.empty? && request.get?
        if mic_class.public_instance_methods.include?(request.request_method + '_list') 
          mic_class.new.send('GET_list', self)
          return true
        end
      end

      action_name = [ request.request_method , pieces.first ].compact.join('_')

      if mic_class.public_instance_methods.include?(action_name) &&
        mic_class.instance_method(action_name).arity === (pieces.empty? ? 1 : pieces.size )
        pieces.shift
        mic_class.new.send(action_name, self, *pieces)
        return true
      end  
      
      if mic_class.public_instance_methods.include?(request.request_method) &&
         mic_class.instance_method(request.request_method).arity === (pieces.size + 1)
         mic_class.new.send(request.request_method, self, *pieces)
         return true
      end
      
      raise Bad_Bunny::HTTP_404, "Bunny Not Found to handle: #{response.request_method} #{response.path}"
    end   
  end
  
end # === Bunny_Mating
