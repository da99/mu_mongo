# models/Message.rb

class Test_Model_Message_Create < Test::Unit::TestCase

	def club
		Club.db_collection.find_one()
	end

	must 'be allowed to be created by member' do
    mem = Message.create(
      regular_member_1, {
        :owner_id => regular_member_1.data._id,
				:username_id => regular_member_1.username_ids.last,
        :target_ids =>  [ club['_id'] ],
        :body => 'test body',
        :emotion => 'poignant',
        :category => 'tweet',
				:privacy => 'public'
      }
    )
    assert_equal mem.data._id, Message.by_id(mem.data._id).data._id
	end
  
  must 'be created even if :target_ids is a String' do
    mem = Message.create(
      admin_member, {
        :owner_id => admin_member.data._id,
				:username_id => admin_member.username_ids.first,
        :target_ids => club['_id'],
        :body => 'test body',
        :emotion => 'poignant',
        :category => 'tweet',
				:privacy => 'public'
      }
    )
    assert_equal mem.data._id, Message.by_id(mem.data._id).data._id
  end

end # === class Test_Model_Message_Create
