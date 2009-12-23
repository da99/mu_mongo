
class Session

  def GET_log_in the_stage
    the_stage.render_html_template
  end

  def GET_log_out the_stage
    the_stage.log_out!
    the_stage.flash.success_msg =  "You have been logged out." 
    the_stage.redirect! '/'
  end

  def POST_log_in the_stage

    the_stage.log_out!
    
    begin 
      if LogInAttempt.too_many?(request.env['REMOTE_ADDR'])
        raise( LogInAttempt::TooManyFailedAttempts ) 
      end
      mem = Member.authenticate(clean_room)
      self.current_member = mem
      return_page = session.delete :return_page
      the_stage.redirect!( return_page || '/my-work/' )
    rescue Member::NoRecordFound, Member::Incorrect_Password, LogInAttempt::TooManyFailedAttempts
      begin
        LogInAttempt.log_failed_attempt(request.env['REMOTE_ADDR'])
        the_stage.flash.error_msg = "Incorrect info. Try again."
      rescue LogInAttempt::TooManyFailedAttempts
        the_stage.flash.error_msg = "Too many failed log-in attempts. Contact support." 
      end     
    end

    the_stage.redirect! '/log-in/'
       
  end # === post_it_for

end # === Session


