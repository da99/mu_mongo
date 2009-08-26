get '/hearts' do

  describe :heart, :show
  @hearts = [News.first]
  render_mab

end
