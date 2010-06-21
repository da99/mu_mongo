# controls/Clubs.rb
require 'tests/__rack_helper__'

class Test_Control_Clubs_Edit < Test::Unit::TestCase

  must 'require log-in' do
    get "/clubs/hearts/edit/"
    follow_redirect!
    assert_equal "/log-in/", last_request.fullpath
  end

  must 'render for admins' do
    log_in_admin
    get "/clubs/hearts/edit/"
    assert_equal 200, last_response.status
  end

  must 'render for owners' do
    club = create_club(regular_member_1)
    log_in_regular_member_1
    get( club.href + 'edit/' )
    assert_equal 200, last_response.status
  end

  must 'not render for non-owners' do
    club = create_club(regular_member_2)
    log_in_regular_member_1
    get( club.href + 'edit/' )
    assert_equal 403, last_response.status
  end

  must 'show link to edit club' do
    club = create_club(regular_member_1)
    log_in_regular_member_1
    get( club.href )
    assert last_response.body["href=\"#{club.href_edit}"]
  end

  must 'not show link to edit club to a non-owner' do
    owner  = regular_member_1
    viewer = regular_member_3
    club = create_club(owner)
    log_in_regular_member_3
    get( club.href )
    assert_equal nil, last_response.body["href=\"#{club.href_edit}"]
  end

end # === class Test_Control_Clubs_Edit
