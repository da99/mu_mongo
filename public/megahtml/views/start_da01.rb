require "rubygems"
require "sinatra"


  error do
    'Sorry there was a nasty error - ' + env['sinatra.error'].name
  end # error -------------------------------------------------------------------------
  not_found do
    "Sorry, the page you are looking for does not exist. :( "
  end # not_found ----------------------------------------------------------------


get '/' do
  File.read( File.expand_path( File.dirname(__FILE__), 'public/index.html' ) )
end

get '/timer/?' do
  redirect("http://www.busynoise.com/egg")
end


