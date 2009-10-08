describe 'The Main App' do

  it "shows homepage: / " do
    get '/'
    last_response.should.be.ok
    last_response.body.should =~ /megauni/i
  end

  it "shows /busy-noise" do
    get '/busy-noise'
    follow_redirect!
    last_response.should.be.ok
  end

  it "shows /my-egg-timer" do
    get '/my-egg-timer'
    follow_redirect!
    last_response.should.be.ok
  end

  it "adds a slash to a file path" do
    get '/busy-noise'
    follow_redirect!
    last_request.path_info.should.be =~ /noise\/$/
    last_response.should.be.ok
  end

  it "does not add a slash to a missing file: cat.png" do
    get '/dir/cat.png'
    last_response.status.should.be == 404
  end

  it "shows: sitemap.xml as xml" do
    get '/sitemap.xml' 
    last_response.should.be.ok
    last_response.content_type.should.be == 'application/xml;charset=utf-8'
  end

  it "renders /help/" do
    get '/help/'
    last_response.should.be.ok
  end

  it "renders /salud/" do
    get '/salud/'
    last_response.should.be.ok
  end
end # === The Main App


describe 'Main App (Mobile)' do

  it 'renders a mobile version of the homepage' do
    get '/m/'
    last_response.should.be.ok
  end

  it 'add a slash to the mobile homepage path: /m' do
    get '/m'
    follow_redirect!
    last_request.fullpath.should.be == '/m/'
    last_response.should.be.ok
  end

  it 'renders /salud/m/' do
    get '/salud/m/'
    last_response.should.be.ok
  end

  it 'renders /help/m/' do
    get '/help/m/' 
    last_response.should.be.ok
  end

  it 'redirects the following to /salud/m/: /saludm/ /saludm/ /saludmobi/ /saludiphone/ /saludpda/' do
    %w{ /saludm/ /saludm/ /saludmobi/ /saludiphone/ /saludpda/ }.each { |url|
      get url
      follow_redirect!
      last_request.fullpath.should.be == '/salud/m/'
    }
  end

end # ====





