

get '/textile/' do 
  require_ssl!
  describe :textile, :try
  render_mab 
end

post '/textile/' do
  @html_output = textile_to_html(clean_room[:content].to_s)
  describe :textile, :try
  render_mab
end
