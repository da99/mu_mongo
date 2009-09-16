describe 'Heart Link App' do
  it 'renders :show with an :id' do
    n = News.order(:id).first
    get "/heart_link/#{n[:id]}/"
    last_response.should.be.ok
  end

  it 'renders :index' do
    get "/hearts/"
    last_response.should.be.ok
  end

end

