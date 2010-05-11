# controls/Bad_Requests.rb
require 'tests/__rack_helper__'

class Test_Control_Bad_Requests < Test::Unit::TestCase

  must 'redirect any favicon.ico requests to /favicon.ico' do
    get "/my-egg-timer/favicon.ico"
    follow_redirect!
    assert_equal "/favicon.ico", last_request.fullpath
  end

end # === class Test_Control_Bad_Requests
