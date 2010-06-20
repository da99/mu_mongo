# controls/Messages.rb
require 'tests/__rack_helper__'

class Test_Control_Messages_Read < Test::Unit::TestCase

  must 'render /mess/4bbce6566191537a710000a4/ for anyone' do
    get "/mess/4bbce6566191537a710000a4/"
    assert_equal 200, last_response.status
  end

  must 'render a message posted to a life club' do
    mem = regular_member_2
		club = Club.by_id(mem.username_ids.first)
    mess = create_message(mem, club)
    get mess.href
    assert_equal 200, last_response.status
  end
	
end # === class Test_Control_Messages_Read
