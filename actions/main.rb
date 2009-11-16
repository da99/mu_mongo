require 'builder'

get( '/') { 
  describe :main, :show
  render_mab
}


get '/help/' do 
  describe :main, :help
  render_mab
end

get( '/blog/' ) {
  redirect('/news/')
}

get( '/about/' ) { 
  redirect('/help/')
}


get '/salud/' do 
  describe :main, :salud
  render_mab 
end

%w{ /saludm/ /saludm/ /saludmobi/ /saludiphone/ /saludpda/ }.each do |url|
  get( url, :mobile=>false ) {
    redirect('/salud/m/')
  }
end

get( '/reset/' ) {
    TemplateCache.reset
    CSSCache.reset
    redirect( env['HTTP_REFERER'] || '/' )
}


get('/timer/') {
  halt "Not ready yet."
  describe :timer, :show
  render_mab
}


get('/*robots.txt') {
  redirect('/robots.txt')
}


get '/*beeping.*' do
  exts = ['mp3', 'wav'].detect  { |e| e == params['splat'].last.downcase }
  not_found if !exts
  redirect "http://megauni.s3.amazonaws.com/beeping.#{exts}" 
end

get '/sitemap.xml' do
  content_xml_utf8
  @news = News.reverse_order(:created_at).limit(5).all
  builder do |xml|
    eval Pow( options.views, 'sitemap.rb' ).read
  end
end

get '/rss.xml' do
  content_xml_utf8
  @posts = News.get_by_published_at(:limit=>5, :descending=>true)
  main_rss_file = Pow( options.views, 'main_rss.rb' )
  builder do |xml|
    eval main_rss_file.read, nil, main_rss_file.to_s, 1
  end
end


# ===================================================================
#                             Temp Actions
# ===================================================================


get '/economy/' do
  describe :topic, :economy
  render_mab
end

get '/music/' do
  describe :topic, :music
  render_mab
end

get '/sports/' do
  describe :topic, :sports
  render_mab
end

get '/housing/' do
  describe :topic, :housing
  render_mab
end

get '/news/' do
  describe :topic, :news
  render_mab
end

get '/bubblegum/' do # :index
  @news = News.reverse_order(:created_at).limit(10).all
  @news_tags = NewsTag.all
  describe :topic, :bubblegum
  render_mab
end


get '/computer/' do
  describe :topic, :computer
  render_mab
end

get '/preggers/' do
  describe :topic, :preggers
  render_mab
end 

get '/hair/' do
  describe :topic, :hair
  render_mab
end

get '/back-pain/' do
  describe :topic, :back_pain
  render_mab
end

get '/child-care/' do
  describe :topic, :child_care
  render_mab
end

get '/arthritis/' do
  describe :topic, :arthritis
  render_mab
end

get '/flu/' do
  describe :topic, :flu
  render_mab
end

get '/heart/' do
  describe :topic, :heart
  render_mab
end

get '/cancer/' do
  describe :topic, :cancer
  render_mab
end

get '/hiv/' do
  describe :topic, :hiv
  render_mab
end

get '/depression/' do
  describe :topic, :depression
  render_mab
end

get '/dementia/' do
  describe :topic, :dementia
  render_mab
end

get '/meno-osteo/' do
  describe :topic, :meno_osteo
  render_mab
end

get '/health/' do
  describe :topic, :health
  render_mab
end

