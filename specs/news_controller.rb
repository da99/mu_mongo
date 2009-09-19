describe 'News App (public actions)' do

  it 'renders :index' do
    get '/news/'
    last_response.should.be.ok
  end

  it 'renders :show with an :id' do
    n = News.order(:id).first
    get "/news/#{n[:id]}/"
    last_response.should.be.ok
  end

  it 'renders mobile version of :index' do
    get '/news/m/'
    last_response.should.be.ok
  end

  it 'renders :index' do
    get '/news/'
    last_response.should.be.ok
  end

  it 'renders a group by tags' do
    tag = NewsTag.order(:id).first
    get '/news/by_tag/' + tag[:id].to_s + '/'
    last_response.should.be.ok
  end

  it 'renders a group by date' do
    news = News.order(:id).first
    get "/news/by_date/#{news.published_at.year}/#{news.published_at.month}/"
    last_response.should.be.ok
  end

end # ===

describe 'News :new (action)' do

  it 'requires log-in' do
    get '/news/new/', {}, ssl_hash
    follow_redirect!
    last_request.fullpath.should.be == '/log-in/'
  end

  it 'does not allow regular members to view it.' do
    log_in_member
    get '/news/new/', {}, ssl_hash
    last_response.status.should.be == 404
  end

  it 'requires log-in by an admin only.' do
    log_in_admin
    get '/news/new/', {}, ssl_hash
    last_response.should.be.ok
  end

end # ===

describe 'News :create (action)' do
  
  before do
    @path = '/news/'
    @new_values = { :title=>'Vitamin D3 Shop', 
                  :teaser=>'The Teaser',
                  :body=>'New Openining' }
    @path_args = [ @path, @new_values, ssl_hash ]
  end

  it 'does not allow strangers' do
    should.raise(Member::UnauthorizedEditor) {
      post *@path_args
    }
  end

  it 'does not allow members' do
    log_in_member
    should.raise(Member::UnauthorizedEditor) {
      post *@path_args
    }
  end

  it 'allows admins' do
    log_in_admin
    post *@path_args
    follow_redirect!
    follow_redirect!
    last_request.fullpath.should.be =~ /^\/news\/[0-9]+\//
    last_response.should.be.ok
    last_response.body.should.be =~ /#{Regexp.escape(@new_values[:title])}/
    last_response.body.should.be =~ /#{Regexp.escape(@new_values[:body])}/
  end

  it 'redirects to :new and shows error messages' do
    log_in_admin
    post @path, {}, ssl_hash
    follow_redirect!
    follow_redirect!
    last_response.body.should.be =~ /Title is required/
    last_response.body.should.be =~ /Body is required/
  end

end # ===

describe 'News :edit (action)' do
  before do
    @news = News.first
    @edit_path = "/news/#{@news[:id]}/edit/"
  end
  it 'requires log-in' do
    get @edit_path, {}, ssl_hash
    follow_redirect!
    last_request.fullpath.should.be =~ /^\/log\-in/
  end
  it 'is not viewable by members' do
    log_in_member
    get @edit_path, {}, ssl_hash
    last_response.status.should.be == 404
  end
  it 'is viewable by admins' do
    log_in_admin
    get @edit_path, {}, ssl_hash
    last_response.should.be.ok
  end
end # === 

describe 'News :update (action)' do
  before do
    @news = News.first
    @update_path = "/news/#{@news[:id]}/"
  end

  it 'does not allow members to update' do
    log_in_member
    should.raise(Member::UnauthorizedEditor) {
      put @update_path, {:title=>'New Title'}, ssl_hash
    }
  end 

  it 'allows admins to update' do
    log_in_admin
    new_title = "Longevinex Rocks (updated) #{Time.now.utc.to_i}"
    put @update_path, {:title=>new_title}, ssl_hash
    follow_redirect!
    follow_redirect! # The same path but with SSL
    last_response.body.should.be =~ /#{Regexp.escape(new_title)}/
  end

  it 'redirects to :edit and shows error messages.' do
    log_in_admin
    put @update_path, {:title=>'', :body=>''}, ssl_hash
    follow_redirect!
    follow_redirect!
    last_response.body.should.be =~ /Title is required/
    last_response.body.should.be =~ /Body is required/
  end

end # ===

describe 'Hearts App Compatibility' do

  it 'renders mobile version of :index' do
    get '/hearts/m/'
    follow_redirect!
    last_response.should.be.ok
    last_request.fullpath.should.be == '/news/m/'
  end

end # === 
