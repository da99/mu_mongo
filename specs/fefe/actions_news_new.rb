require '__rack__'

class Actions_News_New
  
  include FeFe_Test

  context 'News :new (action)' 

  it 'requires log-in' do
    get '/news/new/', {}, ssl_hash
    follow_ssl_redirect!
    demand_equal '/log-in/', last_request.fullpath
    # get '/log-out/'
  end

  it 'does not allow regular members to view it.' do
    log_in_member
    get '/news/new/', {}, ssl_hash
    demand_equal 404, last_response.status
  end

  it 'requires log-in by an admin only.' do
    log_in_admin
    get '/news/new/', {}, ssl_hash
    demand_equal 200, last_response.status
  end

  
end # ======== News_Actions
