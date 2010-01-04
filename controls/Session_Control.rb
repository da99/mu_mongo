class Session_Control
  include Base_Control

  def GET_log_in 
    render_html_template
  end

  def GET_log_out 
    log_out!
    flash.success_msg =  "You have been logged out." 
    redirect! '/'
  end

  def POST_log_in 

    log_out!
    
    begin 
      mem = Member.authenticate(
        :username=>clean_room[:username], 
        :password=>clean_room[:password], 
        :ip_address=>request.env['REMOTE_ADDR'],
        :user_agent=>request.env['HTT_USER_AGENT']
      )
      self.current_member = mem
      return_page = session.delete(:return_page)
      redirect!( return_page || '/me/' )
    rescue Member::Not_Found, Member::Wrong_Password
      flash.error_msg = "Incorrect info. Try again."
    rescue Member::Password_Reset
      flash.error_msg = "Too many failed log-in attempts. Contact support." 
    end

    redirect! '/log-in/'
       
  end # === post_it_for

end # === Session_Control


