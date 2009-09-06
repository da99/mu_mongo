
get '/media/heart_links/images/*' do
  redirect( 'http://surferhearts.s3.amazonaws.com/heart_links' + File.join('/', params['splat'] ))
end


get '/hearts/' do

  describe :heart, :show
  @hearts = News.reverse_order(:created_at).limit(10).all
  @news_tags = NewsTag.all
  render_mab

end

get '/blog/:year/' do |year|
  redirect("/hearts/by_date/#{year.to_i}/1" )
end

get '/blog/:year/0/' do |year|
  redirect("/hearts/by_date/#{year.to_i}/1" )
end

get '/blog/:year/:month/' do |year, month|
  redirect("/hearts/by_date/#{year.to_i}/#{month.to_i}" )
end

get '/hearts/by_date/:year/:month/' do
  describe :heart, :by_date
  
  year = params[:year].to_i
  month = params[:month].to_i
  year += 2000 if year < 100
  month = 1 if month < 1
  case month
    when 1
      @prev_month = Time.utc(year - 1, 12)
      @next_month = Time.utc(year + 1, 2)
    when 12
      @prev_month = Time.utc(year, 11)
      @next_month = Time.utc(year, 1)
    else
      @prev_month = Time.utc(year, month-1)
      @next_month = Time.utc(year, month+1)    
  end
  @date = Time.utc(year, month)
  @news = News.reverse_order(:published_at).
          where( 'published_at > ? AND published_at <  ?',  @prev_month, @next_month )
  render_mab
end

get %r{/heart_links?/by_category/([0-9]+)\.html?} do |id|
  redirect("/heart_links/by_tag/#{id}")
end

get %r{/heart_links/by_category/([0-9]+)/} do |id|
  redirect("/hearts/by_tag/#{id}")
end

get %r{/hearts/by_tag/([0-9]+)/} do |id|
  describe :heart, :by_tag
  @news_tag = NewsTag[:id=>Integer(id)]
  @news = if !@news_tag
    []
  else
    @news_taggings_dt = NewsTagging.select(:model_id).where(:tag_id=>Integer(id))
    News.where(:id=>@news_taggings_dt).reverse_order(:published_at).all
  end
  render_mab
end

get %r{/hearts?_links?/([0-9]+)\.html?} do |id| # /hearts/20.html
  redirect( "/heart_link/#{ id  }"  )
end

get %r{/hearts?_links/([0-9]+)/} do |id|  #  /hearts_links/29
  redirect( "/heart_link/#{ id }"  )
end

get %r{/heart_link/([0-9]+)/} do |id| #  /heart_link/29
  describe :heart, :link
  @heart = News[:id=>Integer(id)]
  not_found if !@heart
  render_mab
end
