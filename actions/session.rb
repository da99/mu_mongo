get "/log\-?in" do
  require_ssl!
  describe :session, :new
  render_mab
end

get "/log-out" do
  session.clear
  flash(:success_msg,  "You have been logged out." )
  redirect('/')
end

post( "/log-in"  ) do

    # Before clearing session, get the most recent URL from the stack.
    target_url = session[:desired_uri] || '/admin' 

    # Clear everything else in the session.
    session.clear
           
    begin 
      mem = Member.authenticate(clean_room['username'], clean_room['password'], request.env['REMOTE_ADDR'])
      session[:member_username] = mem.username
      redirect( target_url )
    rescue Member::NoRecordFound, Member::IncorrectPassword
      flash(:error_msg ,  "Incorrect info. Try again." )
    rescue LoginAttempt::TooManyFailedAttempts
      flash(:error_msg,  "Too many failed login attempts. Contact support."  )
    end
    
    redirect '/log-in'   
       
end # === post_it_for

