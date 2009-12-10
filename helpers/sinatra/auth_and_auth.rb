


helpers do # ===============================   

  # === Member related helpers ========================

  def require_log_in?
    !@dont_require_log_in
  end

  def dont_require_log_in
    @dont_require_log_in = true
  end

  def require_log_in! *perm_levels

    return true if perm_levels.empty? && logged_in?

    if !logged_in? 
      if request.get?
        session[:return_page] = request.fullpath
        redirect('/log-in/')
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
    #return_page = session[:return_page]
    
    # I hate this because it requires specific implementation knowledge
    # about Rack::Flash. However, until I figure out a better solution,
    # here goes:
    #flash_session = session[:__FLASH__]
    
    session.clear
    #session[:return_page] = return_page
    keep_flash

    # session[:__FLASH__] = flash_session 
  end
  
  def logged_in?
    session[:member_id] && current_member && !current_member.new?
  end # === def      

  def current_member=(mem)
      raise "CURRENT MEMBER ALREADY SET" if logged_in?
      session[:member_id] = mem.original_data._id
  end    

  def current_member
    return nil if !session[:member_id]
    @current_member ||= Member.by_id( session[:member_id] )
    return nil if !@current_member
    @current_member
  end # === def
  
      
  
  
end # === helpers
        
        
before {
    
  require_ssl! if logged_in? || request.cookies["logged_in"] || request.post?
    
} # === before  

__END__


  def error
  
    response['Content-Type'] = 'text/html' # In case the controller changed it, like the CSSController.

    if BusyConfig.development?
      return error_wo_customizations if request.get?

      error = Ramaze::Dispatcher::Error.current
      title = error.message

      respond %(
        <div class="error_msg">
          <div class="title">#{error.message}</div>
          <div class="msg"><pre>
            #{PP.pp request, '', 200}
            <br /><hr /><br />
            #{error.backtrace.join("\n            ")}
          </pre></div>
        </div>
      ).ui
      
    end
    

    
    begin
      respond Pow!('../public/500.html').read
    rescue
      respond %~
        <html>
          <head>
            <title>Error Page</title>
          </head>
          <body>
            Something went wrong. Check back later :(
          </body>
        </html>
      ~.unindent
    end
      
  end

   # ==================================================================
    # Methods to handle permission levels.
    # ==================================================================
    def __perm_levels__
      @perm_levels ||={}
    end

    def set_security_level( new_level, *actions )
      actions.each { |raw_target_action| 
        target_action = raw_target_action.to_sym
        if __perm_levels__.has_key?(target_action)
          raise PermissionLevelAlreadySet,  "Permission level can not be set more than once: #{raw_target_action.inspect}" 
        end
        __perm_levels__[target_action] = new_level
      }
    end

    def get_security_level(target_action)
      __perm_levels__.fetch( target_action.to_sym,  Member::NO_ACCESS )
    end
