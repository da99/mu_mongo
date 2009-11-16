
# configure do
#   set :news_actions, [ :show, 
#   :new, :create, :edit, :update, :delete] 
# end

helpers {
  def news_tags
    @all_news_tags ||= News.get_tags
  end
}

allow(News) {

  new # NEW
  show 
  edit 

  create do # CREATE
    success_msg "Save: #{doc.title}"
  end

  update do |doc|
    success_msg "Update: #{doc.title}"
  end

  delete do |doc| # DELETE

    success_msg "Delete: #{doc.title}"

    error(:no_record, :unauthorized) {
      success_msg 'Deleted.'
    }

    redirect '/my-work/'

  end

}

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
  @news = News.get_by_published_at(:descending=>true, :startkey=>@next_month, :endkey=>@prev_month)
  render_mab
end # ===

get %r{/news/by_tag/([0-9]+)/} do |id|
  tags = { 167 => 'stuff_for_dudes', 
            168 => 'stuff_for_dudettes', 
            169 => 'stuff_for_pets', 
            170 => 'stuff_for_mommies_and_dads', 
            171 => 'edible_delicious', 
            172 => 'books_articles', 
            173 => 'techie_wonders', 
            174 => 'miscellaneous', 
            175 => 'art_design', 
            176 => 'surfer_hearts' 
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

__END__


# get '/news/new/' do # NEW
#   require_log_in!
#   begin
#     News.new(current_member)
#   rescue News::UnauthorizedNew
#     pass
#   end
#   describe News, :new
#   render_mab
# end

# post '/news/' do # CREATE
#   require_log_in!
#   begin
#     n = New.create current_member, clean_room
#     flash.success_msg = "Saved: #{n.title}"
#     redirect "/news/#{n._id}/"
#   rescue News::UnauthorizedCreator
#     pass
#   rescue News::Invalid
#     flash.error_msg = to_html_list($!.doc.errors)
#     redirect "/news/new/"
#   end
# 
# end

# get '/news/:id/' do # SHOW
#   begin
#     @news = News.read(current_member, clean_room[:id])
#   rescue News::NoRecordFound, News::UnauthorizedReader
#     pass 
#   end
# 
#   describe News, :show
#   render_mab
# end 

# get '/news/:id/edit/' do # EDIT
#   require_log_in!
#   begin
#     @news = News.edit(current_member, clean_room[:id])
#   rescue News::NoRecordFound, News::UnauthorizedEditor
#     pass
#   end
# 
#   describe News, :edit
#   render_mab
# end

# put '/news/:id/' do # UPDATE
#   require_log_in!
#   begin
#     doc = News.update(current_member, clean_room)
#     flash.success_msg = "Updated: #{doc.title}"
#     redirect request.path_info
#   rescue News::NoRecordFound, News::UnauthorizedUpdator
#     pass
#   rescue News::Invalid
#     flash.error_msg = to_html_list($!.doc.errors)
#     redirect("/news/#{$!.doc._id}/edit/")
#   end
# end

# delete '/news/:id/' do # DELETE
#   require_log_in!
#   begin
#     doc = News.delete!( current_member, clean_room[:id])
#     flash.success_msg = "Deleted: #{doc.title}"
#   rescue News::NoRecordFound, News::UnauthorizedDeletor
#     flash.success_msg = "Deleted."
#   end
# 
#   redirect '/my-work/'
# end


