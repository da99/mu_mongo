
require '__rack__'

class Actions_Main_Mobile

  
  include FeFe_Test

context 'Main App (Mobile)' 

  it 'renders a mobile version of the homepage' do
    get '/m/'
    demand_match 200, last_response.status
  end

  it 'add a slash to the mobile homepage path: /m' do
    get '/m'
    follow_redirect!
    demand_match '/m/', last_request.fullpath
    demand_match 200, last_response.status
  end

  it 'renders /salud/m/' do
    get '/salud/m/'
    demand_match 200, last_response.status
  end

  it 'renders /help/m/' do
    get '/help/m/' 
    demand_match 200, last_response.status
  end

  it 'redirects the following to /salud/m/: /saludm/ /saludm/ /saludmobi/ /saludiphone/ /saludpda/' do
    %w{ /saludm/ /saludm/ /saludmobi/ /saludiphone/ /saludpda/ }.each { |url|
      get url
      follow_redirect!
      demand_match '/salud/m/', last_request.fullpath
    }
  end

end # ====





