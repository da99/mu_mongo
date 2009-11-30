
require '__rack__'

class Actions_Member_Account

  
  include FeFe_Test

  context 'Member :account action' 

  it "redirects to /log-in/ for non-members" do
    get '/account/', {}, ssl_hash
    follow_ssl_redirect!
    demand_match '/log-in/', last_request.fullpath
    demand_match 200, last_response.status
  end

  it "renders ok for members" do
    log_in_member
    get '/account/', {}, ssl_hash
    demand_match 200, last_response.status
  end

  it "renders ok for admins" do
    log_in_admin
    get '/account/', {}, ssl_hash
    demand_match 200, last_response.status
  end

end # === 


