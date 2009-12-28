

get '/textile/' do 
  require_ssl!
  controller :textile
  action :try
  render_mab 
end

post '/textile/' do
  @html_output = textile_to_html(clean_room[:content].to_s)
  controller :textile
  action :try
  render_mab
end
