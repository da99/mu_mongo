

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
    post '/member/', {:password=>'myuni4vr', :confirm_password=>'myuni4vr'}, ssl_hash
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


describe 'Member :account action' do

  it "redirects to /log-in/ for non-members" do
    get '/account/', {}, ssl_hash
    follow_ssl_redirect!
    last_request.fullpath.should.be == '/log-in/'
    last_response.should.be.ok
  end

  it "renders ok for members" do
    log_in_member
    get '/account/', {}, ssl_hash
    last_response.should.be.ok
  end

  it "renders ok for admins" do
    log_in_admin
    get '/account/', {}, ssl_hash
    last_response.should.be.ok
  end

end # === 


