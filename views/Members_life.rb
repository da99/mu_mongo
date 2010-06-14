# MAB   ~/megauni/templates/en-us/mab/Members_life.rb
# SASS  ~/megauni/templates/en-us/sass/Members_life.sass
# NAME  Members_life

class Members_life < Base_View

  def life_club_href
    "/life/#{username}/"
  end

  def title 
    "#{app.env['results.username']}'s Fan Club"
  end

  def username
    app.env['results.username']
  end
  
  def owner
    app.env['results.owner']
  end

  def owner?
    current_member == owner
  end

  def username_id
    @cache['username_id'] ||= app.env['results.owner'].username_hash.index(username)
  end

  def stream
    []
  end
  
end # === Members_life 
