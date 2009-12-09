require '__rack__'

class Actions_News_Hearts_Compatibility
  
  include FeFe_Test

  
  context  'Hearts App Compatibility' 
  
  it 'renders :index' do
    get "/hearts/"
    follow_redirect!
    demand_equal 200, last_response.status
    demand_equal "/news/", last_request.fullpath
  end
  
  it 'renders mobile version of :index' do
    get '/hearts/m/'
    follow_redirect!
    demand_equal '/hearts/', last_request.fullpath 
    follow_redirect!
    demand_equal 200, last_response.status
    demand_equal '/news/', last_request.fullpath
  end

  it 'redirects /blog/ to /news/' do 
    get '/blog/'
    follow_redirect!
    demand_equal '/news/', last_request.fullpath
    demand_equal 200, last_response.status
  end

  it 'redirects /about/ to /help/' do
    get '/about/'
    follow_redirect!
    demand_equal '/help/', last_request.fullpath
    demand_equal 200, last_response.status
  end

  it 'redirects blog archives to news archives. ' +
     '(E.g.: /blog/2007/8/)' do
    get '/blog/2007/8/'
    follow_redirect!
    demand_equal '/news/by_date/2007/8/', last_request.fullpath
    demand_equal 200, last_response.status
  end

  it 'redirects archives by_category to news archives by_tag. ' +
     '(E.g.: /heart_links/by_category/16/)' do
      get '/heart_links/by_category/167/'
      follow_redirect!
      demand_equal '/news/by_tag/167/', last_request.fullpath 
  end

  it 'redirects a "/heart_link/10/" to "/news/10/".' do
    @news = News.by_published_at(:limit=>1)
    get "/heart_link/#{@news._id}/"
    follow_redirect!
    demand_equal "/news/#{@news._id}/", last_request.fullpath 
    demand_equal 200, last_response.status 
  end

  it 'responds with 404 for a heart link that does not exist.' do
    get "/heart_link/1000000/"
    follow_redirect!
    demand_equal 404, last_response.status 
  end

  it 'redirects "/rss/" to "/rss.xml".' do
    get '/rss/'
    follow_redirect!
    demand_equal '/rss.xml', last_request.fullpath 
    demand_equal 200, last_response.status
    last_response_should_be_xml
  end

end # === 
