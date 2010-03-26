# controls/Sessions.rb
require 'tests/__rack_helper__'

class Test_Control_Sessions_Create < Test::Unit::TestCase

  before do
    @username = 'da01'
    @password = 'myuni4vr'
  end

  must 'redirects if missing ending slash' do
    get '/log-in' 
    follow_redirect!
    follow_redirect!
    assert_match( /\<button/, last_response.body )
  end

  must 'redirects to SSL' do
    get '/log-in/'
    assert_not_equal "https", last_request.env["rack.url_scheme"]
    follow_redirect!
    assert_equal "https", last_request.env["rack.url_scheme"]
    assert_match( /\<button/, last_response.body )
  end

  must 'renders ok on SSL' do
    get '/log-in/', {}, ssl_hash
    assert_equal 200, last_response.status
    assert_match( /Log-in/, last_response.body )
  end

  must 'redirects and displays errors' do
    post '/log-in/', {}, ssl_hash
    follow_ssl_redirect!
    assert_match( /Incorrect info. Try again./, last_response.body)
  end

  must 'allows Member access if creditials are correct.' do
    post '/log-in/', {:username=>@username, :password=>@password}, ssl_hash
    follow_ssl_redirect!
    assert_equal '/account/', last_request.path_info
    assert_equal 200, last_response.status
  end

  must 'won\'t accept any more log-in attempts (even with right creditials) ' +
     'after limmust is reached' do
    10.times do |i|
      post '/log-in/', {:username=>'wrong', :password=>'wrong'}, ssl_hash
    end
    post '/log-in/', {:username=>@username, :password=>@password}, ssl_hash
    follow_ssl_redirect!
    assert_equal '/log-in/', last_request.path_info
    LogInAttempt.delete
  end


end # === class Test_Control_Sessions_Create
