require 'builder' # For RSS

controller :main do 

  get( '/' ) { 
    action :show
    render_mab
  }

  redirect {
    from :about
    to :help
  }

  get( '/help/' ) {
    action :help
    render_mab
  }

  get( '/salud/' ) { 
    action :salud
    render_mab 
  }

end # === controller :main

redirect {
  from :blog 
  to :news
}

redirect {
  from '/*robots.txt'
  to '/robots.txt'
}

redirect {
  from *(%w{ /saludm/ /saludm/ /saludmobi/ /saludiphone/ /saludpda/ })
  to '/salud/m/'
}

# %w{ /saludm/ /saludm/ /saludmobi/ /saludiphone/ /saludpda/ }.each do |url|
#   get( url, :mobile=>false ) {
#     redirect('/salud/m/')
#   }
# end

get( '/reset/' ) do
    TemplateCache.reset
    CSSCache.reset
    redirect( env['HTTP_REFERER'] || '/' )
end


get('/timer/') do
  halt "Not ready yet."
  controller :timer
  action :show
  render_mab
end

get '/*beeping.*' do
  exts = ['mp3', 'wav'].detect  { |e| e == params['splat'].last.downcase }
  not_found if !exts
  redirect "http://megauni.s3.amazonaws.com/beeping.#{exts}" 
end

get '/sitemap.xml' do
  content_xml_utf8
  @news = News.reverse_order(:created_at).limit(5).all
  builder do |xml|
    file = Pow( options.views, 'sitemap.rb' )
    eval file.read, file.to_s, 1
  end
end

get '/rss.xml' do
  content_xml_utf8
  @posts = News.by_published_at(:limit=>5, :descending=>true)
  main_rss_file = Pow( options.views, 'main_rss.rb' )
  builder do |xml|
    eval main_rss_file.read, nil, main_rss_file.to_s, 1
  end
end


# ===================================================================
#                             Temp Actions
# ===================================================================

controller :topic do

  get '/economy/' do
    action  :economy
    render_mab
  end

  get '/music/' do
    action  :music
    render_mab
  end

  get '/sports/' do
    action  :sports
    render_mab
  end

  get '/housing/' do
    action  :housing
    render_mab
  end

  get '/news/' do
    action  :news
    render_mab
  end

  get '/bubblegum/' do # :index
    @news = News.reverse_order(:created_at).limit(10).all
    @news_tags = NewsTag.all
    action  :bubblegum
    render_mab
  end


  get '/computer/' do
    action  :computer
    render_mab
  end

  get '/preggers/' do
    action  :preggers
    render_mab
  end 

  get '/hair/' do
    action  :hair
    render_mab
  end

  get '/back-pain/' do
    action  :back_pain
    render_mab
  end

  get '/child-care/' do
    action  :child_care
    render_mab
  end

  get '/arthritis/' do
    action  :arthritis
    render_mab
  end

  get '/flu/' do
    action  :flu
    render_mab
  end

  get '/heart/' do
    action  :heart
    render_mab
  end

  get '/cancer/' do
    action  :cancer
    render_mab
  end

  get '/hiv/' do
    action  :hiv
    render_mab
  end

  get '/depression/' do
    action  :depression
    render_mab
  end

  get '/dementia/' do
    action  :dementia
    render_mab
  end

  get '/meno-osteo/' do
    action  :meno_osteo
    render_mab
  end

  get '/health/' do
    action  :health
    render_mab
  end

end # === controller :topics
