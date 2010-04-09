# controls/Hellos.rb

require 'tests/__rack_helper__'

class Test_Control_Hellos < Test::Unit::TestCase

  must 'show homepage: /' do
    get '/'
    assert_equal 200, last_response.status
  end

  must "shows /busy-noise" do
    get '/busy-noise'
    follow_redirect!
    assert_equal 200, last_response.status
  end

  must "shows /my-egg-timer" do
    get '/my-egg-timer'
    follow_redirect!
    assert_equal 200, last_response.status
  end

  must "adds a slash to a file path" do
    get '/busy-noise'
    assert_match( /noise\/$/, last_response.headers['Location'] )
  end

  must "does not add a slash to a missing file: cat.png" do
    get '/dir/cat.png'
    assert_equal 404, last_response.status
  end

  must "shows: sitemap.xml as xml" do
    get '/sitemap.xml' 
    assert_equal 200, last_response.status
    assert_equal last_response.content_type,  'application/xml; charset=utf-8'
  end

  must "redirect /help/ to /clubs/megauni/" do
    get '/help/'
    follow_redirect!
    assert_equal "/clubs/megauni/", last_request.fullpath
  end


  must "renders /salud/" do
    get '/salud/'
    assert_equal 200, last_response.status
  end

end # === class Test_Control_Hellos
