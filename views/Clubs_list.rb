# MAB   /home/da01tv/MyLife/apps/megauni/templates/en-us/mab/Clubs_list.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Clubs_list.sass
# NAME  Clubs_list

class Clubs_list < Base_View

  def title 
    'Full list of clubs.'
  end

  def clubs
    @cache[:clubs] ||= @app.env['results.clubs'].map { |r| 
      r[:href] = "/clubs/#{r['filename']}/"
      r
    }
  end

end # === Clubs_list 
