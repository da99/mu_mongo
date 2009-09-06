get( '/' ) {
  describe :main, :show
  render_mab
}


get '/help/' do
  describe :main, :help
  render_mab
end

get( '/blog/' ) {
  redirect('/hearts')
}

get( '/about/' ) {
  redirect('/help')
}


get '/salud/' do
  describe :main, :salud
  render_mab :layout=>nil
end


get( '/reset/' ) {
    TemplateCache.reset
    CSSCache.reset
    redirect( env['HTTP_REFERER'] || '/' )
}


get('/timer/') {
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


