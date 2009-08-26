get '/hearts' do

  describe :heart, :show
  @hearts = News.reverse_order(:created_at).limit(10).all
  render_mab

end

get '/media/heart_links/images/*' do
  redirect( 'http://surferhearts.s3.amazonaws.com/heart_links' + File.join('/', params['splat'] ))
end
