# middleware/Old_App_Redirect.rb
require 'tests/__rack_helper__'

class Test_Control_Bad_Agents < Test::Unit::TestCase

  must 'redirect any path ending with .php to http://www.bing.com/' do
    get '/get_orders_list.php'
    assert_equal 'http://www.bing.com/', last_response.headers['Location']
  end

  must 'redirect any path ending with .asp to http://www.bing.com/' do
    get '/downloads/search.asp'
    assert_equal 'http://www.bing.com/', last_response.headers['Location']
  end

end # === class Test_Control_Old_Apps_Read
