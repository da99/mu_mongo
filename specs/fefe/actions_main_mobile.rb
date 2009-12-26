
require '__rack__'

class Actions_Main_Mobile

  
  include FeFe_Test

  context 'Main App (Mobile)' 

  it 'sets the mobilize cookie and redirects /m/ to homepage' do
    get '/m/'
    follow_redirect!
    demand_equal '/', last_request.fullpath
    demand_equal 'yes', last_request.cookies['use_mobile_version']
  end

  it 'add a slash to the mobile homepage path: /m' do
    get '/m'
    follow_redirect!
    follow_redirect!
    demand_equal '/', last_request.fullpath
  end

  it 'redirects /salud/m/ to /salud/' do
    get '/salud/m/'
    demand_equal 302, last_response.status
    demand_equal '/salud/', last_response.headers['Location']
  end

  it 'redirects /help/m/ to /help/' do
    get '/help/m/' 
    demand_equal 302, last_response.status
    demand_equal '/help/', last_response.headers['Location']
  end

  it 'redirects the following to /salud/m/: /saludm/ /saludm/ /saludmobi/ /saludiphone/ /saludpda/' do
    %w{ /saludm/ /saludm/ /saludmobi/ /saludiphone/ /saludpda/ }.each { |url|
      get url
      follow_redirect!
      demand_equal '/salud/m/', last_request.fullpath
    }
  end

end # ====





