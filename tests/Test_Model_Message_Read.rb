# models/Message.rb

class Test_Model_Message_Read < Test::Unit::TestCase

  must 'by able to retrieve messages by published month' do
    mess = Message.by_published_at( 2007, 1 ).to_a
    assert_equal 34, mess.size 
  end

  must 'by able to retrieve messages by month range for published at' do
    mess = Message.by_published_at( 2007, 1, 2007, 3 ).to_a
    assert_equal 96, mess.size 
  end

end # === class Test_Model_Message_Read
