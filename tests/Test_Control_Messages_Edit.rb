# controls/Messages.rb
require 'tests/__rack_helper__'

class Test_Control_Messages_Edit < Test::Unit::TestCase

  def club
    Club.db_collection.find_one
  end

  def create_message mem
    Message.create(
      mem, 
      :owner_id=> mem.username_ids.first.to_s,
      :target_ids => [club['_id']],
      :body => 'test body',
      :emotion => 'poignant',
      :category => 'tweet',
      :privacy => 'public'
    )
  end

  must 'not allow stranger to view.' do
    get '/mess/1/edit/'
    follow_redirect!
    assert_equal '/log-in/', last_request.fullpath
  end

  must 'allow an admin to edit message, even if not the owner.' do
    log_in_admin
    get '/mess/1/edit/'
    assert last_response.ok?
  end

  must 'allow owner to view.' do
    log_in_member
    mem = create_message(regular_member_1)
    get "/mess/#{mem.data._id}/edit/"
    assert 200, last_response.status
  end

end # === class Test_Control_Messages_Edit
