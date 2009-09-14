
configure do
  resty :news do 
    viewer :STRANGER
    c_u_d :ADMIN, [:title, :body, :teaser, :published_at, :tags]
  end
end

get '/news/' do
  @news = News.reverse_order(:created_at).limit(10).all
  @news_tags = NewsTag.all
  describe :news, :index 
  render_mab
end


