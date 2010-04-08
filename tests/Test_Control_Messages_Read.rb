# controls/Messages.rb
require 'tests/__rack_helper__'

class Test_Control_Messages_Read < Test::Unit::TestCase

  must 'render /mess/4bbce6566191537a710000a4/ for anyone' do
    get "/mess/4bbce6566191537a710000a4/"
    assert_equal 200, last_response.status
  end

end # === class Test_Control_Messages_Read
