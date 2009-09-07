helpers {
 
    def mobile_request?(path = nil)
      (path || request.path_info).strip =~ /\/m\/?$/
    end

    def mobile_path(raw_path)
      return raw_path if !raw_path.is_a?(String)
      return raw_path if mobile_request?(raw_path)
      File.join( raw_path.strip, 'm/')
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
            env['rack.url_scheme'] == 'https' || 
              env['SERVER_PORT'].to_i == 443 ||
                request.port == 443)
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
