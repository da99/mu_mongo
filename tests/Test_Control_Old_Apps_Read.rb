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
    follow_redirect!
    assert_match( /over to the new address/, last_response.body )
  end 

  must 'should redirect www.busynoise.com/ to /busy-noise/moving.html' do
    domain = 'www.busynoise.com'
    get '/', {}, { 'HTTP_HOST' =>domain  }
    follow_redirect!
    assert_equal '/busy-noise/moving.html', last_request.fullpath
  end

  must 'should redirect www.busynoise.com/egg to /busy-noise/moving.html' do
    domain = 'www.busynoise.com'
    get '/egg', {}, { 'HTTP_HOST' =>domain  }
    follow_redirect!
    follow_redirect!
    assert_equal '/busy-noise/moving.html', last_request.fullpath
  end

  must 'shows a moving message for www.busynoise.com/egg/' do
    domain =  'www.busynoise.com/'
    get '/egg/', {}, { 'HTTP_HOST'=> domain }
    follow_redirect!
    assert_match( /This website has moved/, last_response.body )
  end

  must 'shows a moving message for www.busynoise.com/egg' do 
    domain =  'www.busynoise.com'
    get '/egg', {}, { 'HTTP_HOST'=> domain }
    follow_redirect!
    follow_redirect!
    assert_match( /This website has moved/, last_response.body  )
  end


end # === class Test_Control_Old_Apps_Read
