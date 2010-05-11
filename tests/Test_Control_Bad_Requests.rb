# controls/Bad_Requests.rb
require 'tests/__rack_helper__'

class Test_Control_Bad_Requests < Test::Unit::TestCase

  must 'redirect any favicon.ico requests to /favicon.ico' do
    get "/my-egg-timer/favicon.ico"
    follow_redirect!
    assert_equal "/favicon.ico", last_request.fullpath
  end
  
  must 'redirect /SWF/main.swf to http://www.bing.com/SWF/main.swf' do
    get "/SWF/main.swf"
    follow_redirect!
    assert_equal "http://www.bing.com/SWF/main.swf", last_response.headers['Location']
  end

  must 'redirect /(null)/ to http://www.bing.com/(null)/' do
    get "/(null)/"
    follow_redirect!
    assert_equal "http://www.bing.com/(null)/", last_response.headers['Location']
  end

end # === class Test_Control_Bad_Requests
