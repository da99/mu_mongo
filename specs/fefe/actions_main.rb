require '__rack__'

class Actions_Main
  
  include FeFe_Test

  context 'The Main App' 

  it "shows homepage: / " do
    get '/'
    demand_equal 200, last_response.status
    demand_regex_match( /megauni/i, last_response.body )
  end

  it "shows /busy-noise" do
    get '/busy-noise'
    follow_redirect!
    demand_equal 200, last_response.status
  end

  it "shows /my-egg-timer" do
    get '/my-egg-timer'
    follow_redirect!
    demand_equal 200, last_response.status
  end

  it "adds a slash to a file path" do
    get '/busy-noise'
    demand_regex_match( /noise\/$/, last_response.headers['Location'] )
  end

  it "does not add a slash to a missing file: cat.png" do
    get '/dir/cat.png'
    demand_equal 404, last_response.status
  end

  it "shows: sitemap.xml as xml" do
    get '/sitemap.xml' 
    demand_equal 200, last_response.status
    demand_equal last_response.content_type,  'application/xml; charset=utf-8'
  end

  it "renders /help/" do
    get '/help/'
    demand_equal 200, last_response.status
  end

  it "renders /salud/" do
    get '/salud/'
    demand_equal 200, last_response.status
  end
end # === The Main App

