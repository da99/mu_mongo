
# =============================== SESSION ACTIONS ==============================

get "/log-in/" do
  require_ssl!
  controller :session
  action :new
  render_mab
end


get "/log-out/" do
  log_out!
  flash.success_msg =  "You have been logged out." 
  redirect('/')
end


post( "/log-in/"  ) do

    log_out!
    
    begin 
      raise( LogInAttempt::TooManyFailedAttempts ) if LogInAttempt.too_many?(request.env['REMOTE_ADDR'])
      mem = Member.authenticate(clean_room)
      self.current_member = mem
      return_page = session.delete :return_page
      redirect( return_page || '/my-work/' )
    rescue Member::NoRecordFound, Member::Incorrect_Password, LogInAttempt::TooManyFailedAttempts
      begin
        LogInAttempt.log_failed_attempt(request.env['REMOTE_ADDR'])
        flash.error_msg = "Incorrect info. Try again."
      rescue LogInAttempt::TooManyFailedAttempts
        flash.error_msg = "Too many failed log-in attempts. Contact support." 
      end     
    end

    redirect '/log-in/'
       
end # === post_it_for

