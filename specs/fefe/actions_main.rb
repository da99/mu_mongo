require '__rack__'

class Actions_Main
  
  include FeFe_Test

context 'The Main App' 

  it "shows homepage: / " do
    get '/'
    demand_match 200, last_response.status
    demand_regex_match /megauni/i, last_response.body  
  end

  it "shows /busy-noise" do
    get '/busy-noise'
    follow_redirect!
    demand_match 200, last_response.status
  end

  it "shows /my-egg-timer" do
    get '/my-egg-timer'
    follow_redirect!
    demand_match 200, last_response.status
  end

  it "adds a slash to a file path" do
    get '/busy-noise'
    follow_redirect!
    demand_regex_match /noise\/$/, last_request.path_info  
    demand_match 200, last_response.status
  end

  it "does not add a slash to a missing file: cat.png" do
    get '/dir/cat.png'
    demand_match 404, last_response.status
  end

  it "shows: sitemap.xml as xml" do
    get '/sitemap.xml' 
    demand_match 200, last_response.status
    demand_match last_response.content_type,  'application/xml;charset=utf-8'
  end

  it "renders /help/" do
    get '/help/'
    demand_match 200, last_response.status
  end

  it "renders /salud/" do
    get '/salud/'
    demand_match 200, last_response.status
  end
end # === The Main App

