# controls/Clubs.rb
require 'tests/__rack_helper__'

class Test_Control_Clubs_Edit < Test::Unit::TestCase

  def create_club(mem)
    id = rand(20000)
    club = Club.create(mem, :filename=>"#{id}", :title=>"Club: #{id}", 
                       :teaser=>"Teaser for: Club #{id}"
                      )
  end

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

end # === class Test_Control_Clubs_Edit
