

# ============= Include lib files.
# require Pow!( '../lib/wash' )
# require Pow!( '../lib/to_html' )

set :valid_resource_actions, [:view, :index, :show, :create, :list, :edit, :update, :trash, :untrash]

helpers do # ===============================   

  # === Member related helpers ========================
  
  def require_log_in!
    session[:return_page] = request.fullpath
    redirect('/log-in/')
  end

  def log_out!
    return_page = session[:return_page]
    session.clear
    session[:return_page] if return_page
  end
  
  def logged_in?
    session[:member_username] && !current_member.new?
  end # === def      

  def current_member=(mem)
      raise "CURRENT MEMBER ALREADY SET" if mem && session[:member_username]
      session[:member_username] = mem.username
  end    

  def current_member
    return nil if !session[:member_username]
    @current_member ||= Member[:username => session[:member_username] ]
    return nil unless @current_member
    @current_member
  end # === def
  
  def check_creditials!
    
    dev_log_it("CREDITIAL CHECK >>> #{current_action[:controller].inspect} #{current_action[:action].inspect}")
    
    return true if logged_in? && current_member.has_power_of?( current_action[:perm_level] )
    return true if current_action[:perm_level].eql?( :STRANGER )
    
    if request.get?
      session[:return_page] = request.fullpath
      redirect('/log-in/')
    else
      render_error_msg( "Not logged in. Login first and try again.", 200  )
    end
    
  end # === def check_creditials!            
  
  
end # === helpers
        
        
before {
    
    require_ssl! if request.cookies["logged_in"] || request.post?
    
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

    def set_permission_level( new_level, *actions )
      actions.each { |raw_target_action| 
        target_action = raw_target_action.to_sym
        if __perm_levels__.has_key?(target_action)
          raise PermissionLevelAlreadySet,  "Permission level can not be set more than once: #{raw_target_action.inspect}" 
        end
        __perm_levels__[target_action] = new_level
      }
    end

    def get_permission_level(target_action)
      __perm_levels__.fetch( target_action.to_sym,  Member::NO_ACCESS )
    end
