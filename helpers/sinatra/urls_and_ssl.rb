
# If path is a String, adds a slash at the end if one does 
# not exist.
#
# Options:
#   :mobile => Default is true, unless path has a period.
#              E.g.: /sitemap.xml. 
#              Set to true to force using a path, even with
#              period in the path.
def get( raw_path, opts={}, &blok)
  path = raw_path.is_a?(String) && !raw_path['.'] ? 
            File.join(raw_path.strip, '/') : 
            raw_path
  
  if path.is_a?(String) 
    use_mobile = opts.delete(:mobile) 
    if (use_mobile.nil? && !path['.']) || use_mobile
      m_path = File.join( path, 'm/' )
      Sinatra::Application.get m_path, opts, &blok
    end
  end

  Sinatra::Application.get path, opts, &blok
end


before {
  
  if request.env['HTTP_USER_AGENT'] == 'MSIE 7.0'
    halt 404, "404 - Not Found"
  end

  # url must not be blank. Sometimes I get error reports where the  URL is blank.
  # I have no idea how that is even possible, so I put this:
  if production? && 
    ( env['REQUEST_URI'].to_s.strip.empty? || 
        request.path_info.to_s.strip.empty? )
    raise( ArgumentError, "POSSIBLE SECURITY ISSUES: URL is blank: #{env['REQUEST_URI'].inspect}, #{request.path_info.inspect}" ) 
  end

  if request.get? && request.path_info =~ /\/m\/?$/
    @mobile_request = true
    #request.path_info = request.path_info.sub(/\/m\/?$/, '/') # File.join(request.path_info, "m/")
  end
    
} # === before  

helpers {
 
    def mobile_request?(path = nil)
      @mobile_request || (path || request.path_info).strip =~ /\/m\/?$/
    end

    def mobile_path(raw_path)
      return raw_path if !raw_path.respond_to?(:to_s)
      return raw_path.to_s if mobile_request?(raw_path.to_s)
      File.join( raw_path.to_s.strip, 'm/')
    end

    def mobile_path_if_requested(raw_path)
      return raw_path if !mobile_request?
      mobile_path raw_path
    end   

    def publicize_path(path)
     File.join( options.public, Wash.path( path ) )
    end

    # Adds either http:// or https://, 
    # along with request.host
    # depending if logged in.
    def urlize(url)
      return url if !url[/^\//]
      full_path = "#{socket_and_host}#{url}"
      logged_in? || using_ssl?  ?
        full_path.sub('http://', 'https://') :
        full_path
    end
    
    def socket_and_host
      "http#{ using_ssl? ? 's' : '' }://#{request.host}"
    end
    
    def using_ssl?
      (env['HTTPS'] == 'on' || 
          env['HTTP_X_FORWARDED_PROTO'] =='https' || 
            env['rack.url_scheme'] == 'https' )
      # This: request.url =~ /\Ahttps\:/ 
      # does not work if being used in a proxy setup.
    end
    
    def require_ssl!
    
      return nil if using_ssl?
      
      if request.xhr? || request.post?
        render_error_msg( "Programmer error. Using unsecure line.", 200  )
      end
            
      # Redirect to SSL
      # SSL detection from: http://www.ruby-forum.com/topic/155956
      redirect 'https://' + request.url.sub('http://', '') , 301 # permanent redirect

    end # === def 


} # === helpers


