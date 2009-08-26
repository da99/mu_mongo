
get '/media/heart_links/images/*' do
  redirect( 'http://surferhearts.s3.amazonaws.com/heart_links' + File.join('/', params['splat'] ))
end


get '/hearts' do

  describe :heart, :show
  @hearts = News.reverse_order(:created_at).limit(10).all
  render_mab

end

get %r{/heart_links?/([0-9]+)\.html?} do |id| # /hearts/20.html
  redirect( "/heart_link/#{ id  }"  )
end

get %r{/heart_links/([0-9]+)} do |id|  #  /heart/29
  redirect( "/heart_link/#{ id }"  )
end

get %r{/heart_link/([0-9]+)} do |id| #  /hearts/29
  describe :heart, :link
  @heart = News[:id=>Integer(id)]
  not_found if !@heart
  render_mab
end
