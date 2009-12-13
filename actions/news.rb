



helpers {
  def news_tags
    @all_news_tags ||= News.tags
  end
}

# =========================================================
#               CRUD actions
# =========================================================

# get '/news/new/' do # NEW
#   crud!
# end

module Sin_Bunny
  
  attr_reader :sin
  
  def initialize sin_scope
    @sin = sin_scope
  end
  
end

class News_Bunny
	
	include Sin_Bunny
	
	def GET_new
		sin.crud!
	end


	def POST # CREATE 
		sin.success_msg { "Save: #{doc.data.title}" }
		sin.crud!
	end

	def GET_list # 
		"list of news items"
	end

	def GET id  # SHOW
		return "id: #{id}"
		sin.dont_require_log_in
		sin.crud! 
	end

	def GET_edit id # EDIT 
		sin.crud! 
	end

	def PUT id  # UPDATE 
		sin.success_msg { "Update: #{doc.data.title}" }
		sin.crud! 
	end

	def DELETE id # DELETE
		success_msg { "Delete: #{doc.data.title}"  }
		redirect_success '/my-work/' 
		crud! 
	end


end # === News_Bunny


set :mic_class_name_suffix, '_Bunny'
set :mic_classes, [News_Bunny]
set :mic_class_names, lambda { mic_classes.map(&:to_s) }

before {

	# require 'rubygems'; require 'ruby-debug'; debugger

	http_meth_downcase   = request.request_method.to_s.downcase
	default_mic_class = options.mic_classes.first
	pieces               = request.path.split('/')

	pieces.shift if pieces.first === ''

	if pieces.empty?
		halt default_mic_class.new(self).send(request.request_method)
	end

	mic_class_name = pieces.first.gsub(/[^a-zA-Z0-9_]/, '_').split('_').map(&:capitalize).join('_') + options.mic_class_name_suffix

	if options.mic_class_names.include?(mic_class_name)
		pieces.shift

		mic_class = Object.const_get(mic_class_name)

		if pieces.empty? && request.get?
			if mic_class.public_instance_methods.include?(request.request_method + '_list') 
				halt mic_class.new(self).send('GET_list')
			end
		end

		action_name = [ request.request_method , pieces.first ].compact.join('_')

		if mic_class.public_instance_methods.include?(action_name) &&
			mic_class.instance_method(action_name).arity === (pieces.empty? ? 0 : pieces.size - 1 )
			pieces.shift
			halt mic_class.new(self).send(action_name, *pieces)
		end  
		
		if mic_class.public_instance_methods.include?(request.request_method) &&
			 mic_class.instance_method(request.request_method).arity === (pieces.size)
			halt mic_class.new(self).send(request.request_method, *pieces)
		end
	end

}

post '/news/' do # CREATE 
  success_msg { "Save: #{doc.data.title}" }
  crud!
end

get '/news/:id/' do |id| # SHOW
  dont_require_log_in
  crud! 
end

get '/news/edit/:id' do # EDIT 
  crud! 
end

put '/news/:id/' do |id| # UPDATE 
  success_msg { "Update: #{doc.data.title}" }
  crud! 
end

delete '/news/:id/' do |id| # DELETE
  success_msg { "Delete: #{doc.data.title}"  }
  redirect_success '/my-work/' 
  crud! 
end


# =========================================================
#               READ-related actions
# =========================================================

get '/news/by_date/:year/:month/' do
  controller :news
  action :by_date
  
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
  @news = News.by_published_at(:descending=>true, :startkey=>@next_month, :endkey=>@prev_month)
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


