# middleware/Old_App_Redirect.rb
require 'tests/__rack_helper__'

class Test_Control_Bad_Agents < Test::Unit::TestCase

  must 'redirect any path ending with .php to http://www.bing.com/' do
    get '/get_orders_list.php'
    assert_equal 'http://www.bing.com/', last_response.headers['Location']
  end
  
  must 'redirect any deep path (/.+/.+/index.php) to http://www.bing.com/' do
    get '/Site_old/administrator/index.php'
    assert_equal 'http://www.bing.com/', last_response.headers['Location']
  end

  must 'redirect any path ending with .asp to http://www.bing.com/' do
    get '/downloads/search.asp'
    assert_equal 'http://www.bing.com/', last_response.headers['Location']
  end

  must 'redirect any user agent containing "panscient" to http://www.bing.com' do
    get '/', {}, 'HTTP_USER_AGENT' => 'panscient.com'
    assert_equal 'http://www.bing.com/', last_response.headers['Location']
  end

  must 'redirect any user agent containing "Yahoo! Slurp/" and ' +
       'looking for path start with /SlurpConfirm404' do
    get( 
      '/SlurpConfirm404/drodgers.htm', 
      {}, 
      'HTTP_USER_AGENT' => 'Mozilla/5.0 (compatible; Yahoo! Slurp/3.0; http://help.yahoo.com/help/us/ysearch/slurp)'
    )
    assert_equal 'http://www.bing.com/', last_response.headers['Location']
  end

end # === class Test_Control_Old_Apps_Read
