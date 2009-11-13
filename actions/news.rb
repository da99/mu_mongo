
# configure do
#   set :news_actions, [ :show, 
#   :new, :create, :edit, :update, :delete] 
# end

helpers {
  def news_tags
    @all_news_tags ||= News.get_tags
  end
}


get '/news/new/' do # NEW
  require_log_in!
  doc = begin
    News.get_for_creator(current_member)
  rescue News::UnauthorizedCreator
    pass
  end
  describe News, :new
  render_mab
end

post '/news/' do # CREATE
  require_log_in!
  n = begin
    News.get_for_creator(current_member)
  rescue News::UnauthorizedCreator
    pass
  end

  begin
    n.create current_member, clean_room
    flash.success_msg = "Saved: #{n.title}"
    redirect "/news/#{n._id}/"
  rescue News::Invalid
    flash.error_msg = to_html_list(n.errors)
    redirect "/news/new/"
  end

end

get '/news/:id/' do # SHOW
  doc = begin
    News.get_for_viewer(current_member, clean_room[:id])
  rescue News::NoRecordFound, News::UnauthorizedViewer
    pass
  end

  describe News, :show
  render_mab
end 

get '/news/:id/edit/' do # EDIT
  require_log_in!
  d = begin
    News.get_for_editor(current_member, clean_room[:id])
  rescue News::NoRecordFound, News::UnauthorizedEditor
    pass
  end

  describe News, :edit
  render_mab
end

put '/news/:id/' do # UPDATE
  require_log_in!
  d = begin
    News.get_for_updator(current_member, clean_room[:id])
  rescue News::NoRecordFound, News::UnauthorizedUpdator
    pass
  end

  begin
    d.update clean_room
    flash.success_msg = "Updated: #{n.title}"
    redirect request.path_info
  rescue News::Invalid
    flash.error_msg = to_html_list(d.errors)
    redirect("/news/#{n._id}/edit/")
  end
end

delete '/news/:id/' do # DELETE
  require_log_in!
  d = begin
    News.get_for_deletor current_member, clean_room[:id]
  rescue News::NoRecordFound, News::UnauthorizedDeletor
  end

  flash.success_msg = "Deleted: #{d.title}"
  redirect '/'
end

get '/news/by_date/:year/:month/' do
  describe :news, :by_date
  
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
end # ===

get %r{/news/by_tag/([0-9]+)/} do |id|
  tags = { 167 => stuff_for_dudes, 
            168 => stuff_for_dudettes, 
            169 => stuff_for_pets, 
            170 => stuff_for_mommies_and_dads, 
            171 => edible_delicious, 
            172 => books_articles, 
            173 => techie_wonders, 
            174 => miscellaneous, 
            175 => art_design, 
            176 => surfer_hearts 
  }
  tag_id = Integer(id) 
  @news_tag = tags[ tag_id ]
  @news = if !@news_tag
    redirect("/news/by_tag/unknown-tag/")
  else
    redirect("/news/by_tag/#{@news_tag}/")
  end
end

get %r{/news/by_tag/([a-zA-Z0-9\-]+)/} do |tag_name|
  describe :news, :by_tag
  @news_tag = tag_name
  @news = News.get_by_tag @news_tag
  render_mab
end


# =========================== HEART LINKS COMPATIBILITY =================================


get '/media/heart_links/images/*' do
  redirect( 'http://surferhearts.s3.amazonaws.com/heart_links' + File.join('/', params['splat'] ))
end


get '/hearts/' do
  redirect( request.fullpath.sub('hearts', 'news') )
end

get '/blog/:year/' do |year|
  redirect("/news/by_date/#{year.to_i}/1" )
end

get '/blog/:year/0/' do |year|
  redirect("/news/by_date/#{year.to_i}/1" )
end

get '/blog/:year/:month/' do |year, month|
  redirect("/news/by_date/#{year.to_i}/#{month.to_i}/" )
end

get '/hearts/by_date/:year/:month/' do |year,month|
  redirect("/news/by_date/#{year.to_i}/#{month.to_i}/")
end # ===

get %r{/heart_links?/by_category/([0-9]+)\.html?} do |id|
  redirect("/news/by_tag/#{id}/")
end

get %r{/heart_links/by_category/([0-9]+)/} do |id|
  redirect("/news/by_tag/#{id}/")
end

get %r{/hearts/by_tag/([0-9]+)/} do |id| 
  redirect("/news/by_tag/#{id}/")
end

get %r{/hearts?_links?/([0-9]+)\.html?} do |id| # /hearts/20.html
  redirect( "/news/#{ id  }/"  )
end

get %r{/hearts?_links/([0-9]+)/} do |id|  #  /hearts_links/29/
  redirect( "/news/#{ id }/"  )
end

get %r{/heart_link/([0-9]+)/} do |id| #  /heart_link/29/
  redirect("/news/#{id}/")
end

get '/rss/?' do
  redirect('/rss.xml')
end
