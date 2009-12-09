
require '__rack__'

class Actions_Member_Create
  
  include FeFe_Test

  context 'Member :new/:create action' 

  it 'redirects to SSL version of page' do
    get '/sign-up/' 
    follow_redirect!
    demand_equal 'on', last_request.env['HTTPS']
  end 

  it 'redirects and shows password errors' do 
    post '/member/', {:add_life=>'friend', :add_life_username=>'da01111'}, ssl_hash
    follow_ssl_redirect!
    demand_regex_match /Password must be at least 5 characters in length/, last_response.body 
  end

  it 'redirects and shows username errors' do
    post '/member/', {:add_life=>'friend', :add_life_username=>'d', :password=>'myuni4vr', :confirm_password=>'myuni4vr'}, ssl_hash
    follow_ssl_redirect!
    demand_regex_match(
      /Username must be between 2 and 20 characters/, 
      last_response.body 
    )
  end

  it 'redirects and shows username uniqueness errors' do
    vals = { :password=>'myuni4vr', 
             :confirm_password=>'myuni4vr', 
             :add_life=>'friend', 
             :add_life_username=>'admin-member'}
    post '/member/', vals, ssl_hash
    follow_ssl_redirect!
    demand_regex_match( /Username already taken\: admin\-member/, last_response.body )
  end

end # ===
