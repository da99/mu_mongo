# controls/Clubs.rb
require 'tests/__rack_helper__'

class Test_Control_Clubs_Read < Test::Unit::TestCase

  def create_club
    log_in_admin
    num=rand(1000)
    Club.create(admin_member, 
      :title=>"R2D2 #{num}", :filename=>"r2d2_#{num}", :teaser=>"Teaser for: R2D2 #{num}"
    )
  end

  must 'be viewable by non-members' do
    club = create_club
    get "/clubs/#{club.data.filename}/"
    assert_match(/#{club.data.title}/, last_response.body)
  end

end # === class Test_Control_Clubs_Read
