describe 'News App (public actions)' do

  it 'renders :index' do
    get '/news/'
    last_response.should.be.ok
  end

  it 'renders :show with an :id' do
    n = News.by_tag( :hearts, :limit=>1 )
    get "/news/#{n._id}/"
    last_response.should.be.ok
  end

  it 'renders mobile version of :index' do
    get '/news/m/'
    follow_redirect!
    last_response.should.be.ok
  end

  it 'renders :index' do
    get '/news/'
    last_response.should.be.ok
  end

  it 'renders a group by tags' do
    tags = News.tags
		get "/news/by_tag/#{tags.first}/"
    last_response.should.be.ok
  end

  it 'renders a group by date' do
    news = News.by_published_at(:limit=>1, :startkey=>'2000-01-01')
    get "/news/by_date/#{news.published_at.year}/#{news.published_at.month}/"
    last_response.should.be.ok
  end

end # ===

describe 'News :new (action)' do

  it 'requires log-in' do
    get '/news/new/', {}, ssl_hash
    follow_ssl_redirect!
    last_request.fullpath.should.be == '/log-in/'
		get '/log-out/'
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
		post *@path_args
		last_response.body.should =~ /Not logged in. Log-in first and try again/
		get '/log-out/'
  end

  it 'does not allow members' do
    log_in_member
    post *@path_args
    last_response.status.should.be == 404
  end

  it 'allows admins' do
    log_in_admin
    post *@path_args
    follow_ssl_redirect!
    last_request.fullpath.should.be =~ /^\/news\/[A-Za-z0-9]{6,32}\//
    last_response.should.be.ok
    last_response.body.should.be =~ /#{Regexp.escape(@new_values[:title])}/
    last_response.body.should.be =~ /#{Regexp.escape(@new_values[:body])}/
  end

  it 'redirects to :new and shows error messages' do
    log_in_admin
    post @path, {}, ssl_hash
    follow_ssl_redirect!
    last_response.body.should.be =~ /Title is required/
    last_response.body.should.be =~ /Body is required/
  end

end # ===

describe 'News :edit (action)' do
  before do
    @news = News.by_published_at(:limit=>1)
    @edit_path = "/news/#{@news._id}/edit/"
  end
  it 'requires log-in' do
    get @edit_path, {}, ssl_hash
    follow_ssl_redirect!
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
    @news = News.by_published_at(:limit=>1)
    @update_path = "/news/#{@news._id}/"
  end

  it 'does not allow members to update' do
    log_in_member
    put @update_path, {:title=>'New Title'}, ssl_hash
		last_response.status.should.be == 404
  end 

  it 'allows admins to update' do
    log_in_admin
    new_title = "Longevinex Rocks (updated) #{Time.now.utc.to_i}"
    put @update_path, {:title=>new_title}, ssl_hash
    follow_ssl_redirect! 
    last_response.body.should.be =~ /#{Regexp.escape(new_title)}/
  end

  it 'redirects to :edit and shows error messages.' do
    log_in_admin
    put @update_path, {:title=>'', :body=>''}, ssl_hash
    follow_ssl_redirect!
		last_request.fullpath.should.be == "/news/#{@news._id}/edit/"
    last_response.body.should.be =~ /Title is required/
    last_response.body.should.be =~ /Body is required/
  end

end # ===

describe 'Hearts App Compatibility' do

  it 'renders mobile version of :index' do
    get '/hearts/m/'
    follow_redirect!
    last_request.fullpath.should.be == '/hearts/'
    follow_redirect!
    last_response.status.should == 200
    last_request.fullpath.should.be == '/news/'
  end

  it 'redirects /blog/ to /news/' do 
    get '/blog/'
    follow_redirect!
    last_request.fullpath.should.be == '/news/'
    last_response.should.be.ok
  end

  it 'redirects /about/ to /help/' do
    get '/about/'
    follow_redirect!
    last_request.fullpath.should.be == '/help/'
    last_response.should.be.ok
  end

  it 'redirects blog archives to news archives. ' +
     '(E.g.: /blog/2007/8/)' do
    get '/blog/2007/8/'
    follow_redirect!
    last_request.fullpath.should.be == '/news/by_date/2007/8/'
    last_response.should.be.ok
  end

  it 'redirects archives by_category to news archives by_tag. ' +
     '(E.g.: /heart_links/by_category/16/)' do
      get '/heart_links/by_category/167/'
      follow_redirect!
      last_request.fullpath.should.be == '/news/by_tag/167/'
  end

  it 'redirects a "/heart_link/10/" to "/news/10/".' do
		@news = News.by_published_at(:limit=>1)
    get "/heart_link/#{@news._id}/"
    follow_redirect!
    last_request.fullpath.should.be == "/news/#{@news._id}/"
		last_response.status.should.be == 200
    last_response.should.be.ok
  end

  it 'responds with 404 for a heart link that does not exist.' do
    get "/heart_link/1000000/"
    follow_redirect!
    last_response.status.should.be == 404
  end

  it 'redirects "/rss/" to "/rss.xml".' do
    get '/rss/'
    follow_redirect!
    last_request.fullpath.should.be == '/rss.xml'
    last_response.should.be.ok
    last_response_should_be_xml
  end

end # === 
