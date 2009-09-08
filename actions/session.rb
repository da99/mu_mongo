get "/log\-in/" do
  require_ssl!
  describe :session, :new
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
      mem = Member.authenticate(clean_room['username'], clean_room['password'], request.env['REMOTE_ADDR'])
      session[:member_username] = mem.username
      redirect( session[:return_page] || '/account/' )
    rescue Member::NoRecordFound, Member::IncorrectPassword
      flash.error_msg = "Incorrect info. Try again."
    rescue LoginAttempt::TooManyFailedAttempts
      flash.error_msg =   "Too many failed log-in attempts. Contact support." 
    end
    
    redirect '/log-in'   
       
end # === post_it_for

