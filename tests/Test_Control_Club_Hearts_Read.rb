# controls/Clubs.rb
require 'tests/__rack_helper__'

class Test_Control_Club_Hearts_Read < Test::Unit::TestCase

  must 'render /club/hearts/' do
    get '/club/hearts/'
    assert_equal 200, last_response.status
  end

  must 'redirects /hearts/ to /club/hearts/' do
    get "/hearts/"
    follow_redirect!
    assert_equal( /\/club\/heart/, last_request.fullpath)
  end
  
  must 'redirects /hearts/m/ to /clubs/hearts/' do 
    get '/hearts/m/'
    follow_redirect!
    assert_equal '/clubs/hearts/', last_request.fullpath 
  end

  must 'redirects /blog/ to /hearts/' do 
    get '/blog/'
    follow_redirect!
    assert_equal '/news/', last_request.fullpath
    assert_equal 200, last_response.status
  end

  must 'redirects /about/ to /help/' do
    get '/about/'
    follow_redirect!
    assert_equal '/help/', last_request.fullpath
    assert_equal 200, last_response.status
  end

  must 'redirects blog archives to news archives. ' +
     '(E.g.: /blog/2007/8/)' do
    get '/blog/2007/8/'
    follow_redirect!
    assert_equal '/news/by_date/2007/8/', last_request.fullpath
    assert_equal 200, last_response.status
  end

  must 'redirects archives by_category to news archives by_tag. ' +
     '(E.g.: /heart_links/by_category/16/)' do
      get '/heart_links/by_category/167/'
      follow_redirect!
      assert_equal '/news/by_tag/167/', last_request.fullpath 
  end

  must 'redirects a "/heart_link/10/" to "/news/10/".' do
    @news = News.by_published_at(:limit=>1)
    get "/heart_link/#{@news.data._id}/"
    follow_redirect!
    assert_equal "/news/#{@news.data._id}/", last_request.fullpath 
    assert_equal 200, last_response.status 
  end

  must 'responds with 404 for a heart link that does not exist.' do
    get "/heart_link/1000000/"
    follow_redirect!
    assert_equal 404, last_response.status 
  end

  must 'redirects "/rss/" to "/rss.xml".' do
    get '/rss/'
    follow_redirect!
    assert_equal '/rss.xml', last_request.fullpath 
    assert_equal 200, last_response.status
    last_response_should_be_xml
  end


end # === class Test_Control_Club_Hearts_Read
