# MAB   templates/en-us/mab/Clubs_read_e.rb
# SASS  templates/en-us/sass/Clubs_read_e.sass
# NAME  Clubs_read_e


module Base_View_Club

  def title 
    @app.env['results.club'].data.title
  end

  def compile_clubs arr
    arr.map { |club|
      club['href'] = "/uni/#{club['filename']}/"
      club
    }
  end

  def club
    @app.env['results.club']
  end

  def not_life?
    club.life_club?
  end

  def club_href
    club.href
  end

  def club_href_edit
    club.href_edit
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

  def club_updator?
    club.updator?(current_member)
  end

  def follower?
    club.follower?(current_member)
  end

  def owner?
    club.owner?(current_member)
  end

  def follower_but_not_owner?
    club.follower?(current_member) && !owner?
  end

  def egg_timers_as_clubs
    @cache_egg_timers_as_clubs ||= [ 
      { :teaser=>'Works on old computers.', :href=>'/my-egg-timer/',    :title=>'Old (my-egg_timer)'},
      { :teaser=>'Works on newer computers.', :href=>'/busy-noise/',  :title=>'New (busy-noise egg timer)'},
    ]
  end

  def old_clubs
    @cache_old_clubs ||= [ 
      { :teaser=>nil, :href=>'/salud/',    :title=>'Salud (Español)'},
      { :teaser=>nil, :href=>'/uni/meno_osteo/',  :title=>'Menopause + Osteoporosis'},
      { :teaser=>nil, :href=>'/uni/back_pain/',  :title=>'Back Pain'},
      { :teaser=>nil, :href=>'/uni/arthritis/',  :title=>'Rhumatoid Arthritis'},
      { :teaser=>nil, :href=>'/uni/heart/',    :title=>'Heart'},
      { :teaser=>nil, :href=>'/uni/dementia/',    :title=>'Dementia'},
      { :teaser=>nil, :href=>'/uni/flu/',    :title=>'Flu'},
      { :teaser=>nil, :href=>'/uni/depression/',  :title=>'Depression'},
      { :teaser=>nil, :href=>'/uni/child_care/', :title=>'Child Care'},
      { :teaser=>nil, :href=>'/uni/computer/',   :title=>'Computer Use'},
      { :teaser=>nil, :href=>'/uni/hair/',      :title=>'Skin & Hair'},
      { :teaser=>nil, :href=>'/uni/housing/',   :title=>'Housing & Apartments'},
      { :teaser=>nil, :href=>'/uni/health/',    :title=>'Pain & Disease'},
      { :teaser=>nil, :href=>'/uni/preggers/',  :title=>'Pregnancy'}
    ]
  end

  def your_clubs
    @cache_your_clubs ||= if logged_in?
                               compile_clubs(current_member.owned_clubs)
                             else
                               []
                             end
  end

  %w{ stranger member owner insider }.each { |level|
    eval %~
      def #{level}?
        true if The_App.development?
      end
    ~
  }

  def club_type
    club.life? ? 'life' : 'universe'
  end

end # === Base_View_Club
