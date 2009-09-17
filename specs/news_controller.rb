describe 'News App' do

  it 'renders :index' do
    get '/news/'
    last_response.should.be.ok
  end

  it 'renders :show with an :id' do
    n = News.order(:id).first
    get "/news/#{n[:id]}/"
    last_response.should.be.ok
  end

  it 'renders mobile version of :index' do
    get '/news/m/'
    last_response.should.be.ok
  end

  it 'renders :index' do
    get '/news/'
    last_response.should.be.ok
  end

  it 'renders a group by tags' do
    tag = NewsTag.order(:id).first
    get '/news/by_tag/' + tag[:id].to_s + '/'
    last_response.should.be.ok
  end

  it 'renders a group by date' do
    news = News.order(:id).first
    get "/news/by_date/#{news.published_at.year}/#{news.published_at.month}/"
    last_response.should.be.ok
  end

end # ===

describe 'Hearts App Compatibility' do

  it 'renders mobile version of :index' do
    get '/hearts/m/'
    follow_redirect!
    last_response.should.be.ok
    last_request.fullpath.should.be == '/news/m/'
  end

end # === 
