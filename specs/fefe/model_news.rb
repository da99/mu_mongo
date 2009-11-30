require '__rack__'

class Model_News

  include FeFe_Test

  context 'News instance' 

  it 'has :last_modified_at return the first value not nil: :updated_at, :created_at' do
    yesterday = Time.now.utc - 10000
    now = Time.now.utc + 10000
    post = News.new
    post.created_at = yesterday
    demand_match post.last_modified_at, yesterday

    post.updated_at = now
    demand_match post.last_modified_at, now
  end

end # === 'News instance'
