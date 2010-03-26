# middleware/Old_App_Redirect.rb
require 'tests/__rack_helper__'

class Test_Control_Old_Apps_Read < Test::Unit::TestCase


# 
#
# Note: when setting 'SERVER_NAME', the value 
# changes back to the default, 'example.org', 
# after a redirect. 
# 
# This means you won't be able to have multiple 
# redirects if settings a 'SERVER_NAME', because
# must would not reflect real-world conditions.
#
#

  must 'shows a moving message for www.myeggtimer.com' do
    domain = 'www.myeggtimer.com'
    get '/', {}, { 'HTTP_HOST'=> domain }
    assert_match( /over to the new address/, last_response.body )
  end 

  must 'should redirect www.busynoise.com/ to /egg/' do
    domain = 'www.busynoise.com'
    get '/', {}, { 'HTTP_HOST' =>domain  }
    follow_redirect!
    assert_equal '/egg', last_request.fullpath
  end

  must 'shows a moving message for www.busynoise.com/egg/' do
    domain =  'www.busynoise.com/'
    get '/egg/', {}, { 'HTTP_HOST'=> domain }
    assert_equal domain, last_request.host
    assert_equal '/egg/', last_request.fullpath
    assert_match( /This website has moved/, last_response.body )
  end

  must 'shows a moving message for www.busynoise.com/egg' do 
    domain =  'www.busynoise.com'
    get '/egg', {}, { 'HTTP_HOST'=> domain }
    assert_equal last_request.host, domain 
    assert_equal last_request.fullpath, '/egg'
    assert_match( /This website has moved/, last_response.body  )
  end

  must 'renders /bigstopwatch' do
    get '/bigstopwatch'
    assert_equal 200, last_response.status
  end

  must 'renders /bigstopwatch/' do
    get '/bigstopwatch/'
    assert_equal 200, last_response.status
  end


end # === class Test_Control_Old_Apps_Read
