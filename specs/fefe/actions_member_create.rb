
require '__rack__'

class Actions_Member_Create
  
  include FeFe_Test

context 'Member :new/:create action' 

  it 'redirects to SSL version of page' do
    get '/sign-up/' 
    follow_redirect!
    demand_match 'on', last_request.env['HTTPS']
  end 

  it 'redirects and shows password errors' do 
    post '/member/', {}, ssl_hash
    follow_ssl_redirect!
    demand_regex_match /Password is required/, last_response.body 
  end

  it 'redirects and shows username errors' do
    post '/member/', {:password=>'myuni4vr', :confirm_password=>'myuni4vr'}, ssl_hash
    follow_ssl_redirect!
    demand_regex_match /Username is required/, last_response.body 
  end

  it 'redirects and shows username uniqueness errors' do
    vals = {:password=>'myuni4vr', :confirm_password=>'myuni4vr', :username=>Username.first[:username]}
    post '/member/', vals, ssl_hash
    follow_ssl_redirect!
    demand_regex_match /Username is already taken./, last_response.body 
  end

end # ===
