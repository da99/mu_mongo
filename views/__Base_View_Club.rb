# MAB   /home/da01tv/MyLife/apps/megauni/templates/en-us/mab/Clubs_read_e.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME  Clubs_read_e


module Base_View_Club

  def title 
    @app.env['results.club'].data.title
  end

  def compile_clubs arr
    arr.map { |club|
      club['href'] = "/clubs/#{club['filename']}/"
      club
    }
  end

  def club
    @app.env['results.club']
  end

  def club_href
    "/clubs/#{club.data.filename}/"
  end

  def club_href_e
    File.join(club_href, 'e/')
  end

  def club_href_qa
    File.join(club_href, 'qa/')
  end

  def club_href_news
    File.join(club_href, 'news/')
  end
  
  def club_id
    club.data._id
  end

  def club_title
    club.data.title
  end

  def club_filename
    club.data.filename
  end
  
  def club_teaser
    club.data.teaser
  end

  def messages
    app.env['results.messages']
  end

  def potential_follower?
    club.potential_follower?(current_member)
  end

  def follower?
    club.follower?(current_member)
  end

  def follow_href
    club.follow_href
  end
  
  def egg_timers_as_clubs
    @cache['egg_timers_as_clubs'] ||= [ 
      { :teaser=>'Works on old computers.', :href=>'/my-egg-timer/',    :title=>'Old (my-egg_timer)'},
      { :teaser=>'Works on newer computers.', :href=>'/busy-noise/',  :title=>'New (busy-noise egg timer)'},
    ]
  end

  def old_clubs
    @cache['old_clubs'] ||= [ 
      { :teaser=>nil, :href=>'/salud/',    :title=>'Salud (Español)'},
      { :teaser=>nil, :href=>'/clubs/back_pain/',  :title=>'Back Pain'},
      { :teaser=>nil, :href=>'/clubs/child_care/', :title=>'Child Care'},
      { :teaser=>nil, :href=>'/clubs/computer/',   :title=>'Computer Use'},
      { :teaser=>nil, :href=>'/clubs/hair/',      :title=>'Skin & Hair'},
      { :teaser=>nil, :href=>'/clubs/housing/',   :title=>'Housing & Apartments'},
      { :teaser=>nil, :href=>'/clubs/health/',    :title=>'Pain & Disease'},
      { :teaser=>nil, :href=>'/clubs/preggers/',  :title=>'Pregnancy'}
    ]
  end

  def your_clubs
    @cache['your_clubs'] ||= if logged_in?
                               compile_clubs(current_member.owned_clubs)
                             else
                               []
                             end
  end

end # === Base_View_Club
