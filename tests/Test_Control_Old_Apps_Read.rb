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

  must 'should redirect /back-pain/ to /uni/back_pain/' do
    get '/back-pain/'
    follow_redirect!
    assert_equal '/uni/back_pain/', last_request.fullpath
  end

  must 'redirect /salud/robots.txt to /robots.txt' do
    get '/salud/robots.txt'
    follow_redirect!
    assert_equal '/robots.txt', last_request.fullpath
  end

  must 'redirect /child_care/clubs/child_care/ to /clubs/child_care/' do
    get '/child_care/clubs/child_care/'
    follow_redirect!
    assert_equal '/uni/child_care/', last_request.fullpath
  end

  must 'redirect /back_pain/clubs/back_pain/ to /clubs/back_pain/' do
    get '/back_pain/clubs/back_pain/'
    follow_redirect!
    assert_equal '/uni/back_pain/', last_request.fullpath
  end

  must 'redirect /skins/jinx/css/main_show.css to /stylesheets/en-us/Hellos_list.css' do
    get '/skins/jinx/css/main_show.css'
    follow_redirect!
    assert_equal "/stylesheets/en-us/Hellos_list.css", last_request.fullpath
  end

  must 'redirect /skins/jinx/css/news_show.css to /stylesheets/en-us/Hellos_list.css' do
    get '/skins/jinx/css/news_show.css'
    follow_redirect!
    assert_equal "/stylesheets/en-us/Hellos_list.css", last_request.fullpath
  end

  must 'redirect any 404 url ending in /+/ to ending /' do
    get '/missing/page/+/'
    assert_redirect "/missing/page/"
  end

  must 'redirect /templates/ to /' do
    get '/templates/'
    assert_redirect '/'
  end

end # === class Test_Control_Old_Apps_Read
