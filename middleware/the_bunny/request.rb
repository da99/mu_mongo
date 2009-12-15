
# The request object. See Rack::Request for more info:
# http://rack.rubyforge.org/doc/classes/Rack/Request.html
module Bunny_Request 
  
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
  
end # ==== Rack::Request 

Method_Air_Bags.open_if_collision Bunny_Request, Rack::Request

class Rack::Request
	
	include Bunny_Request

	# Taken with permission from The Sinatra Framework:
	#   Override Rack 0.9.x's #params implementation (see #72 in Sinatra's lighthouse)
	def params
		self.GET.update(self.POST)
	rescue EOFError, Errno::ESPIPE
		self.GET
	end

end # === Rack::Request
