require '__rack__'

class Actions_Session
  
  include FeFe_Test

context 'Log-in for Member' 

  before do
    @username = 'da01'
    @password = 'myuni4vr'
  end

  it 'redirects if missing ending slash' do
    get '/log-in' 
    follow_redirect!
    follow_redirect!
    demand_regex_match /\<button/, last_response.body
  end

  it 'redirects to SSL' do
    get '/log-in/'
    demand_no_match "https", last_request.env["rack.url_scheme"]
    follow_redirect!
    demand_equal "https", last_request.env["rack.url_scheme"]
    demand_regex_match /\<button/, last_response.body
  end

  it 'renders ok on SSL' do
    get '/log-in/', {}, ssl_hash
    demand_equal 200, last_response.status
    demand_regex_match /Log-in/, last_response.body 
  end

  it 'redirects and displays errors' do
    post '/log-in/', {}, ssl_hash
    follow_ssl_redirect!
    demand_regex_match /Incorrect info. Try again./, last_response.body
  end

  it 'allows Member access if creditials are correct.' do
    post '/log-in/', {:username=>@username, :password=>@password}, ssl_hash
    follow_ssl_redirect!
    demand_equal '/account/', last_request.path_info
    demand_equal 200, last_response.status
  end

  it 'won\'t accept any more log-in attempts (even with right creditials) ' +
     'after limit is reached' do
    10.times do |i|
      post '/log-in/', {:username=>'wrong', :password=>'wrong'}, ssl_hash
    end
    post '/log-in/', {:username=>@username, :password=>@password}, ssl_hash
    follow_ssl_redirect!
    demand_equal '/log-in/', last_request.path_info
    LogInAttempt.delete
  end

end # ===
