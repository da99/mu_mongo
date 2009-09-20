

describe 'Member :new/:create action' do

  it 'redirects to SSL version of page' do
    get '/sign-up/' 
    follow_redirect!
    last_request.env['HTTPS'].should.be == 'on'
  end 

  it 'redirects and shows password errors' do 
    post '/member/', {}, ssl_hash
    follow_ssl_redirect!
    last_response.body.should.be =~ /Password is required/
  end

  it 'redirects and shows username errors' do
    post '/member/', {}, ssl_hash
    follow_ssl_redirect!
    last_response.body.should.be =~ /Username is required/
  end

  it 'redirects and shows username uniqueness errors' do
    vals = {:password=>'myuni4vr', :confirm_password=>'myuni4vr', :username=>Username.first[:username]}
    post '/member/', vals, ssl_hash
    follow_ssl_redirect!
    last_response.body.should.be =~ /Username is already taken./
  end

end # ===


