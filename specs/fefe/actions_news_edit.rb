require '__rack__'

class Actions_News_Edit
  
  context  'News :edit (action)' 
  
  before do
    @news = News.by_published_at(:limit=>1)
    @edit_path = "/news/#{@news._id}/edit/"
  end
  
  it 'requires log-in' do
    get @edit_path, {}, ssl_hash
    follow_ssl_redirect!
    demand_regext_match  /^\/log\-in/,  last_request.fullpath
  end
  
  it 'is not viewable by members' do
    log_in_member
    get @edit_path, {}, ssl_hash
    demand_match 404, last_response.status
  end
  
  it 'is viewable by admins' do
    log_in_admin
    get @edit_path, {}, ssl_hash
    demand_match 200, last_response
  end
  
end # === 

