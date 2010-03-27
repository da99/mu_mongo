# controls/Sessions.rb
require 'tests/__rack_helper__'

class Test_Control_Sessions_Create < Test::Unit::TestCase

  def username
    'da01'
  end

  def password
    'myuni4vr'
  end

  must 'renders ok on SSL' do
    get '/log-in/', {}, ssl_hash
    assert_equal 200, last_response.status
    assert_match( /Log-in/, last_response.body )
  end

  must 'redirects and displays errors' do
    post '/log-in/', {}, ssl_hash
    follow_redirect!
    assert_match( /Incorrect info. Try again./, last_response.body)
  end

  must 'allows Member access if creditials are correct.' do
    post '/log-in/', {:username=>regular_username_1, :password=>regular_password_1}, ssl_hash
    follow_redirect!
    assert_equal '/today/', last_request.path_info
  end

  must 'won\'t accept any more log-in attempts (even with right creditials) ' +
     'after limmust is reached' do
    10.times do |i|
      post '/log-in/', {:username=>'wrong', :password=>'wrong'}, ssl_hash
    end
    post '/log-in/', {:username=>username, :password=>password}, ssl_hash
    follow_redirect!
    assert_equal '/log-in/', last_request.path_info
  end


end # === class Test_Control_Sessions_Create
