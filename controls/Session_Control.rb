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
      if LogInAttempt.too_many?(request.env['REMOTE_ADDR'])
        raise( LogInAttempt::TooManyFailedAttempts ) 
      end
      mem = Member.authenticate(clean_room)
      self.current_member = mem
      return_page = session.delete :return_page
      redirect!( return_page || '/my-work/' )
    rescue Member::Not_Found, Member::Wrong_Password, LogInAttempt::TooManyFailedAttempts
      begin
        LogInAttempt.log_failed_attempt(request.env['REMOTE_ADDR'])
        flash.error_msg = "Incorrect info. Try again."
      rescue LogInAttempt::TooManyFailedAttempts
        flash.error_msg = "Too many failed log-in attempts. Contact support." 
      end     
    end

    redirect! '/log-in/'
       
  end # === post_it_for

end # === Session_Control


