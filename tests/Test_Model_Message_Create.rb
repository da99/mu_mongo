# models/Message.rb

class Test_Model_Message_Create < Test::Unit::TestCase

	must 'be allowed to be created' do
    mem = Message.create(
      admin_mem, {
        :owner_id => admin_mem.data._id,
        :target_ids => ["club-san-francisco"],
        :body => 'test body',
        :emotion => 'poignant',
        :category => 'tweet'
      }
    )
    assert_equal mem.data._id, Message.by_id(mem.data._id).data._id
	end

end # === class Test_Model_Message_Create
