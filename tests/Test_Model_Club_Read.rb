# models/Club.rb

class Test_Model_Club_Read < Test::Unit::TestCase

  must 'add club titles to a collection' do
    mess = Message.db_collection.find({}, :limit=>4).to_a
		club_titles   = Club.db_collection.find.map { |club| club['title'] }
		mess_w_titles = Club.add_clubs_to_collection(mess)
		mess.each { |msg|
			assert club_titles.include?(msg['club_title'])
		}
  end

  must 'add club filenames to a collection' do
    mess = Message.db_collection.find({}, :limit=>4).to_a
		filenames   = Club.db_collection.find.map { |club| club['filenames'] }
		mess_w_titles = Club.add_clubs_to_collection(mess)
		mess.each { |msg|
			assert filenames.include?(msg['club_filenames'])
		}
  end

	must 'use /life/{filename}/ for life clubs' do
		mem   = regular_member_1
		un_id, un  = mem.username_hash.to_a.first
		life  = Club.by_id(un_id)
		assert_equal "/life/#{un}/", life.href
	end

end # === class Test_Model_Club_Read
