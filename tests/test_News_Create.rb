require 'tests/__helper__'


class News_Create < Test::Unit::TestCase

	must 'only allow Admins as creators'

  must 'require title'

  must 'require body'

  must 'change published_at to datetime'

  must 'set published_at to now as a default'

  must 'split tag string on new lines'

  must 'strip each tag'

  must 'reject any empty tag' do
    doc = News.create( 
      admin_user, 
      :club   =>'club-hearts',
      :title  => 'My News',
      :teaser => 'My Teaser.',
      :body   => 'My body.',
      :tags   => "tag1\n\n\ntag2\n\ntag3",
      :published_at => nil
    )

    assert_equal %w{ tag1 tag2 tag3 }, doc.data.tags.sort
  end

end # === class News_Create
