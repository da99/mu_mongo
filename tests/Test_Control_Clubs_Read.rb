# controls/Clubs.rb
require 'tests/__rack_helper__'

class Test_Control_Clubs_Read < Test::Unit::TestCase

  def create_club(mem = nil)
    mem ||= regular_member_1
    num=rand(10000)
    Club.create(mem, 
      :title=>"R2D2 #{num}", :filename=>"r2d2_#{num}", :teaser=>"Teaser for: R2D2 #{num}"
    )
  end

  must 'be viewable by non-members' do
    club = create_club
    get "/clubs/#{club.data.filename}/"
    
    assert_match(/#{club.data.title}/, last_response.body)
  end

  must 'present a create message form for logged-in members' do
    club = create_club
    
    log_in_regular_member_1
    get club.href
    form = Nokogiri::HTML(last_response.body).css('form#form_club_message_create').first
    
    assert_equal form.class, Nokogiri::XML::Element
  end

  must 'include club filename for :club_filename in message create form' do
    club = create_club
    
    log_in_regular_member_1
    get club.href
    target_ids = Nokogiri.HTML(last_response.body).css(
      'form#form_club_message_create input[name=club_filename]'
    ).first
    
    assert_equal club.data.filename.to_s, target_ids.attributes['value'].value
  end

  must 'include member\'s username for :username in message create form' do
    club = create_club
    
    log_in_regular_member_1
    get club.href
    un = Nokogiri.HTML(last_response.body).css(
      'form#form_club_message_create input[name=username]'
    ).first
    
    assert_equal regular_member_1.usernames.first, un.attributes['value'].value
  end

  must 'not show follow club link to strangers.' do
    club = create_club
    get club.href
    
    assert_equal nil, last_response.body[club.follow_href]
  end

  must 'not show follow club link to club creator' do
    club = create_club(regular_member_1)

    log_in_regular_member_1
    get club.href
    assert_equal nil, last_response.body[club.follow_href]
  end

  must 'not show "You are following" message to club creator' do
    club = create_club(regular_member_1)

    log_in_regular_member_1
    get club.href
    assert_equal nil, last_response.body['following']
  end

  must 'show follow club link to members.' do
    club = create_club(regular_member_1)

    log_in_regular_member_2
    get club.href
    
    assert_equal club.follow_href, last_response.body[club.follow_href]
  end

	must 'not show follow club link to followers.' do
		club = create_club(regular_member_1)
		club.create_follower( regular_member_2 )

		log_in_regular_member_2
		get club.href

		assert_not_equal club.follow_href, last_response.body[club.follow_href]
	end


  must 'allow members to follow someone else\'s club' do
    club = create_club(regular_member_2)

    log_in_regular_member_1
    get File.join('/', club.href, 'follow/')
    follows = Club.db_collection_followers.find(
      :club_id=>club.data._id, 
      :follower_id=>regular_member_1.data._id
    ).to_a

    assert_equal 1, follows.size
  end

end # === class Test_Control_Clubs_Read
