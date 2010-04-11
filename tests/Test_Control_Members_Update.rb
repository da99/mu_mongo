# controls/Members.rb
require 'tests/__rack_helper__'

class Test_Control_Members_Update < Test::Unit::TestCase

  must 'allow the addition of a new username' do
    rand_un = "new_username_#{rand(10000)}"
    log_in_regular_member_3
    put "/members/", :add_username=>rand_un
    reg3 = Member.by_id(regular_member_3.data._id)
    assert reg3.usernames.include?(rand_un)
  end

  must 'redirect to new username after insertion' do
    rand_un = "new_username_#{rand(20000)}"
    log_in_regular_member_3
    put "/members/", :add_username=>rand_un
    follow_redirect!
    assert_equal "/lives/#{rand_un}/", last_request.fullpath
  end

end # === class Test_Control_Members_Update
