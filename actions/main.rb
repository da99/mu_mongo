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
  @posts = News.reverse_order(:created_at).limit(5).all
  builder do |xml|
    eval Pow( options.views, 'main_rss.rb' ).read
  end
end



