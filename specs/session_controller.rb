

describe 'Log-in for Member' do

  before do
    @username = 'da01'
    @password = 'myuni4vr'
  end

  it 'redirects if missing ending slash' do
    get '/log-in' 
    follow_redirect!
    follow_redirect!
    last_response.body.should =~ /\<button/
  end

  it 'redirects to SSL' do
    get '/log-in/'
    last_request.env["rack.url_scheme"].should.not.be == "https"
    follow_redirect!
    last_request.env["rack.url_scheme"].should.be == "https"
    last_response.body.should =~ /\<button/
  end

  it 'renders ok on SSL' do
    get '/log-in/', {}, ssl_hash
    last_response.should.be.ok
    last_response.body.should =~ /Log-in/
  end

  it 'redirects and displays errors' do
    post '/log-in/', {}, ssl_hash
    follow_ssl_redirect!
    last_response.body.should =~ /Incorrect info. Try again./
  end

  it 'allows Member access if creditials are correct.' do
    post '/log-in/', {:username=>@username, :password=>@password}, ssl_hash
    follow_ssl_redirect!
    last_request.path_info.should == '/account/'
    last_response.should.be.ok
  end

  it 'won\'t accept any more log-in attempts (even with right creditials) ' +
     'after limit is reached' do
    10.times do |i|
      post '/log-in/', {:username=>'wrong', :password=>'wrong'}, ssl_hash
    end
    post '/log-in/', {:username=>@username, :password=>@password}, ssl_hash
    follow_ssl_redirect!
    last_request.path_info.should == '/log-in/'
    LogInAttempt.delete
  end

end # ===
