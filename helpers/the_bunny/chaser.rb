
class Bunny_Chaser

  attr_accessor :env, :request, :response, :params

  def call!(new_env)
    @env      = new_env
    @request  = Rack::Request.new(@env)
    @response = Rack::Response.new

   # return [200, {'Content-Length' => 5.to_s, 'Content-Type' => 'text/plain' }, 'zzzzz' ] 
     
    begin
      
      run_the_request 
      
    rescue Bad_Bunny::HTTP_404
      
      @env['little.microphone.error'] = $!
      @response.set_status 404
      @response.set_body   '<h1>Not Found</h1>'
      
    rescue Bad_Bunny::Unknown_Error
      
      @env['little.microphone.error'] = $!
      @response.set_status 500
      @response.set_body   '<h1>Unknown Error.</h1>'
      
    end

    status, header, body = @response.finish

    # Never produce a body on HEAD requests. Do retain the Content-Length
    # unless it's "0", in which case we assume it was calculated erroneously
    # for a manual HEAD response and remove it entirely.
    if @env['REQUEST_METHOD'] == 'HEAD'
      body = []
      header.delete('Content-Length') if header['Content-Length'] == '0'
    end

    [status, header, body]
  end


  # ------------------------------------------------------------------------------------
  private # ----------------------------------------------------------------------------
  # ------------------------------------------------------------------------------------

  def mic_class_name_suffix
    '_Bunny'
  end

  def mic_classes
    [Hello_Bunny, Request_Bunny]
  end

	def mic_class_names
		@mic_class_names ||= mic_classes.map(&:to_s)
	end

  def run_the_request 
    
    http_meth = request.env_key(:REQUEST_METHOD).to_s
    pieces    = request.env_key(:PATH_INFO).split('/')

    pieces.shift if pieces.first === ''

    if pieces.empty?
      mic_classes.first.new(self).send(http_meth + '_list')
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
          mic_class.new(self).send('GET_list')
          return true
        end
      end

      action_name = [ request.request_method , pieces.first ].compact.join('_')

      if mic_class.public_instance_methods.include?(action_name) &&
        mic_class.instance_method(action_name).arity === (pieces.empty? ? 0 : pieces.size - 1 )
        pieces.shift
        mic_class.new(self).send(action_name, *pieces)
        return true
      end  
      
      if mic_class.public_instance_methods.include?(request.request_method) &&
         mic_class.instance_method(request.request_method).arity === (pieces.size)
         mic_class.new(self).send(request.request_method, *pieces)
         return true
      end
    end   
  end
  
end # === Bunny_Chaser
