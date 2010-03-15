
class News_Mustache < Base_View 

  def news_tags
    @all_news_tags ||= News.tags
  end

end # === News_Mustache


class News_Control
  include Base_Control
  
  
	def PUT id # UPDATE
		success_msg(lambda { |doc| "Update: #{doc.data.title}" })
    params = clean_room.clone
    params[:tags] = begin
                      new_tags = []
                      new_tags += clean_room[:new_tags].to_s.split("\n") 
                      new_tags += clean_room[:tags]
                      new_tags.uniq
                    end
    handle_rest :params=>params
	end

	def GET_list # 
		render_html_template
	end

	def GET id  # SHOW
    env['the.app.news'] = News.by_id(id) 
		render_html_template
	end

	def GET_edit id # EDIT 
    require_log_in! 'ADMIN'
    env['the.app.news'] = News.by_id(id)
    render_html_template
  end

	def DELETE id # DELETE
		success_msg { "Delete: #{doc.data.title}"  }
		redirect_success '/my-work/' 
		crud! 
	end

  # =========================================================
  #               READ-related actions
  # =========================================================

  def GET_by_date  raw_year, raw_month
    year  = raw_year.to_i
    month = raw_month.to_i
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
    @news = News.by_published_at(:descending=>true, :startkey=>@next_month, :endkey=>@prev_month)
    render_html_template
  end # ===

  
end # === News_Control








__END__


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
    controller :news
    action :by_tag
    @news_tag = tag_name
    @news = News.by_tag @news_tag
    render_mab
  end

  # =======================================================================================
  # =========================== HEART LINKS COMPATIBILITY =================================
  # =======================================================================================

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

  get %r{/heart_link/([A-Za-z0-9\-]+)/} do |id| #  /heart_link/29/
    redirect("/news/#{id}/")
  end

  get '/rss/?' do
    redirect('/rss.xml')
  end

  private # ======== 

  def namespace_env key, val
    env["News_Control.#{key}"] = val
  end

  

