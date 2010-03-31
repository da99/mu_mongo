

class Test_View_Base_View_Read < Test::Unit::TestCase

  must 'not turn javascript protocol into anchor tags.' do
    result = Base_View.new(Object.new).auto_link('javascript:alert("hello")')
    assert_equal result, result
  end

end # === class Test_View_Base_View_Read
