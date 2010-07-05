# controls/Messages.rb
require 'tests/__rack_helper__'

class Test_Control_Messages_Create < Test::Unit::TestCase

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

  must 'allow public labels (comma delimited' do
    club = create_club
    log_in_regular_member_1
    body = "Buy it #{rand(1000)}"
    post "/messages/", :club_filename=>club.data.filename, 
      :privacy=>'public',
      :username=>regular_member_1.usernames.last,
      :body=>body,
      :public_labels => 'product , knees'

    mess_labels = Message.db_collection.find(
      :body=>body, 
      :target_ids=>[club.data._id]
    ).first['public_labels']
    assert_equal %w{ product knees }, mess_labels
  end

  must 'redirect to club if club_filename was specified.' do
    club = create_club
    log_in_regular_member_1
    post "/messages/", :club_filename=>club.data.filename,
      :privacy=>'public',
      :username=> regular_member_1.usernames.last,
      :body => rand(12000)
    follow_redirect!

    assert_equal club.href, last_request.fullpath
  end

  must 'redirect to specified return url' do
    club = create_club
    log_in_regular_member_1
    post "/messages/", :club_filename=>club.data.filename,
      :privacy=>'public',
      :username=> regular_member_1.usernames.last,
      :body => rand(12000),
      :return_url => '/test/page/'

    assert_redirect '/test/page/', 303
  end

  must 'ignore return url if is is to an external site' do
    club = create_club
    log_in_regular_member_1
    post "/messages/", :club_filename=>club.data.filename,
      :privacy=>'public',
      :username=> regular_member_1.usernames.last,
      :body => rand(12000),
      :return_url => 'http://www.bing.com/'

    assert_redirect club.href, 303
  end
  
  # ============== CLUBS based on USERNAMES =========================

  must 'allow members to post to a life club.' do
    mem = regular_member_1
    un  = mem.usernames.first
    club = Club.by_filename_or_member_username(un)
    body = "random content #{rand(1000)} #{un}"
    
    log_in_regular_member_1
    
    post( '/messages/', 
      "body"=>body, 
      "body_images_cache"=>"http://28.media.tumblr.com/tumblr_l414x9008E1qba70ho1_500.jpg 500 644", 
      "username"=>un, 
      "message_model"=>"random", 
      "privacy"=>"public", 
      "club_filename"=>un
    )
    
    get club.href
    assert last_response.body[body]
  end

end # === class Test_Control_Messages_Create
