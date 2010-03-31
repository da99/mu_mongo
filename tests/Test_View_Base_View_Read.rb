

class Test_View_Base_View_Read < Test::Unit::TestCase

  must 'run this example: http://gilesbowkett.blogspot.com/2010/03/automating-email-awesome-mini.html' do
    orig = "http://gilesbowkett.blogspot.com/2010/03/automating-email-awesome-mini.html"
    result = Base_View.new(Object.new).auto_link(orig)
    assert_equal "<a href=\"#{orig}\">#{orig}</a>", result
  end
  
  must 'turn valid http urls into HTML anchor tags' do
    result = Base_View.new(Object.new).auto_link('http://www.mises.org')
    assert_equal "<a href=\"http://www.mises.org\">http://www.mises.org</a>", result
  end

  must 'not turn javascript protocol into anchor tags.' do
    original = 'javascript:alert("hello")'
    result = Base_View.new(Object.new).auto_link(original)
    assert_equal original, result 
  end

  must 'not turn any url with more than 2 slash forwards into a link' do
    original = 'http:////www.lewrockwell.com/'
    result = Base_View.new(Object.new).auto_link(original)
    assert_equal original, result
  end

end # === class Test_View_Base_View_Read
