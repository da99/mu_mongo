describe 'News instance' do

  it 'has :last_modified_at return the first value not nil: :updated_at, :created_at' do
    yesterday = Time.now.utc - 10000
    now = Time.now.utc + 10000
    post = News.new
    post.created_at = yesterday
    post.last_modified_at.should.be == yesterday

    post.updated_at = now
    post.last_modified_at.should.be == now
  end

end # === describe 'News instance'
