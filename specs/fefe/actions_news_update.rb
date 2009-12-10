require '__rack__'

class Actions_News_Update
  
  include FeFe_Test


  context 'News :update (action)' 

  before do
    @news = News.by_published_at(:limit=>1)
    @update_path = "/news/#{@news.data._id}/"
  end

  it 'does not allow members to update' do
    log_in_member
    put @update_path, {:title=>'New Title'}, ssl_hash
    demand_equal 404, last_response.status
  end 

  it 'allows admins to update' do
    log_in_admin
    new_title = "Longevinex Rocks (updated) #{Time.now.utc.to_i}"
    put @update_path, {:title=>new_title}, ssl_hash
    follow_ssl_redirect! 
    demand_regex_match /#{Regexp.escape(new_title)}/, last_response.body
  end

  it 'redirects to :edit and shows error messages.' do
    log_in_admin
    put @update_path, {:title=>'', :body=>''}, ssl_hash
    follow_ssl_redirect!
    demand_equal "/news/#{@news.data._id}/edit/", last_request.fullpath
    demand_regex_match /Title is required/, last_response.body
    demand_regex_match /Body is required/, last_response.body
  end

end # ===
