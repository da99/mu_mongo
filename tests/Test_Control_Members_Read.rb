# controls/Members.rb
require 'tests/__rack_helper__'

class Test_Control_Members_Read < Test::Unit::TestCase

  must "redirects to /log-in/ for non-members" do
    get '/account/', {}, ssl_hash
    follow_ssl_redirect!
    assert_equal '/log-in/', last_request.fullpath
    assert_equal 200, last_response.status
  end

  must "renders ok for members" do
    log_in_member
    get '/account/', {}, ssl_hash
    assert_equal 200, last_response.status
  end

  must "renders ok for admins" do
    log_in_admin
    get '/account/', {}, ssl_hash
    assert_equal 200, last_response.status
  end

end # === class Test_Control_Members_Read
