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

end # ===
