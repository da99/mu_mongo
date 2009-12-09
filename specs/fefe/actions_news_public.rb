require '__rack__'

class Actions_News_Public
  
  include FeFe_Test

  
  context  'News App (public actions)' 

  it 'renders :index' do
    get '/news/'
    demand_equal 200, last_response.status
  end

  it 'renders :show with an :id' do
    n = News.by_tag( :hearts, :limit=>1 )
    get "/news/#{n.data._id}/"
    demand_equal 200, last_response.status
  end

  it 'renders mobile version of :index' do
    get '/news/m/'
    follow_redirect!
    demand_equal 200, last_response.status
  end

  it 'renders :index' do
    get '/news/'
    demand_equal 200, last_response.status
  end

  it 'renders a group by tags' do
    tags = News.tags
    get "/news/by_tag/#{tags.first}/"
    demand_equal 200, last_response.status
  end

  it 'renders a group by date' do
    news = News.by_published_at(:limit=>1, :startkey=>'2000-01-01')
    get "/news/by_date/#{news.published_at.year}/#{news.published_at.month}/"
    demand_equal 200, last_response.status
  end

end # ===
