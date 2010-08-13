# models/Club.rb

class Test_Model_Club_Read < Test::Unit::TestCase

  must 'add club titles to a collection' do
    mess = Message.find({}, :limit=>4).to_a
    club_titles   = Club.find({}).map { |club| club['title'] }
    mess_w_titles = Club.add_clubs_to_collection(mess)
    mess.each { |msg|
      assert club_titles.include?(msg['club_title'])
    }
  end

  must 'add club filenames to a collection' do
    mess = Message.find({}, :limit=>4).to_a
    filenames   = Club.find({}).map { |club| club['filenames'] }
    mess_w_titles = Club.add_clubs_to_collection(mess)
    mess.each { |msg|
      assert filenames.include?(msg['club_filenames'])
    }
  end

end # === class Test_Model_Club_Read
