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
  
end # === Clubs_read_e 
