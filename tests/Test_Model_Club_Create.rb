


class Test_Club_Create < Test::Unit::TestCase

  def random_filename
    "movie_#{rand(10000)}"
  end

  must 'set :_id to BSON::ObjectID' do
    fn = random_filename
    club = Club.create(
      admin_member, 
      { :filename => fn,
        :title=>'Gaijin', 
        :teaser=>'Gaijin'}
    )
    assert_equal BSON::ObjectID, club.data._id.class
  end

  must 'require a filename' do
    club = begin
             Club.create(
               admin_member, 
               { :filename=>nil,
                 :title=>'Gaijin', 
                 :teaser=>'Gaijin'}
             )
           rescue Club::Invalid => e
             e.doc
           end
    assert_equal 'Filename is required.', club.errors.first
  end
  
  must 'require a unique filename' do
    filename = Club.db_collection.find_one()['filename']
    club = begin
             Club.create( admin_member,
              {:filename=>filename, :title=>'title', :teaser=>'teaser'} 
             )
           rescue Club::Invalid => e
             e.doc
           end
    assert_equal "Filename, #{filename}, already taken. Please choose another.", club.errors.first
  end

  must 'require a title' do
    club = begin
             Club.create(
               admin_member, 
               { :filename=>random_filename, 
                 :title => nil, 
                 :teaser=>'Gaijin'}
             )
           rescue Club::Invalid => e
             e.doc
           end
    assert_equal 'Title is required.', club.errors.first
  end

  must 'require a teaser' do
    club = begin
             Club.create(
               admin_member, 
               { :filename=>random_filename, 
                 :title=>'Gaijin',
                 :teaser=> nil
                 }
             )
           rescue Club::Invalid => e
             e.doc
           end
    assert_equal 'Teaser is required.', club.errors.first

  end

  must 'set "en-us" as the language.' do
    club = Club.create(
            admin_member, 
            {:filename=>random_filename, 
             :title=>'Gaijin',
             :teaser=>'Relaxed'}
    )
    assert_equal 'en-us', club.data.lang
  end


end # === _create
