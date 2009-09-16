
configure do
  set :news_actions, [:show, :new, :create, :edit, :update, :delete] 
end

get '/news/' do
  @news = News.reverse_order(:created_at).limit(10).all
  @news_tags = NewsTag.all
  describe :news, :index 
  render_mab
end


