# controls/Messages.rb
require 'tests/__rack_helper__'

class Test_Control_Messages_Create < Test::Unit::TestCase

  def create_club(mem = nil)
    mem ||= regular_member_1
    num=rand(10000)
    Club.create(mem, 
      :title=>"R2D2 #{num}", :filename=>"r2d2_#{num}", :teaser=>"Teaser for: R2D2 #{num}"
    )
  end

  must 'allow members to create messages from a club page' do
    club = create_club
    log_in_regular_member_2
    body = "Test body: #{self.class}: 
            allow members to create messages from a club page.
            #{rand(2000)}"
    post "/messages/", :club_filename=>club.data.filename,
      :privacy=>'public',
      :username=> regular_member_2.usernames.last,
      :body => body
    assert_equal [body], Message.db_collection.find(:body=>body).map { |m| m['body'] }
  end

end # === class Test_Control_Messages_Create
