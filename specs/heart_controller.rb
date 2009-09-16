describe 'Heart Link App' do
  it 'renders :show with an :id' do
    n = News.order(:id).first
    get "/heart_link/#{n[:id]}/"
    follow_redirect!
    last_response.should.be.ok
    last_request.fullpath.should == "/news/#{n[:id]}/"
  end

  it 'renders :index' do
    get "/hearts/"
    follow_redirect!
    last_response.should.be.ok
    last_request.fullpath.should == "/news/"
  end

end

