multi_get( '/' ) { 
  describe :main, :show
  render_mab
}


multi_get '/help' do 
  describe :main, :help
  render_mab
end

multi_get( '/blog' ) {
  redirect('/hearts')
}

multi_get( '/about' ) { 
  redirect('/help')
}


multi_get '/salud' do 
  describe :main, :salud
  render_mab 
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






