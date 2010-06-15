# MAB   ~/megauni/templates/en-us/mab/Members_life.rb
# MAB   ~/megauni/templates/en-us/mab/Members_life_e.rb
# MAB   ~/megauni/templates/en-us/mab/Members_life_qa.rb
# MAB   ~/megauni/templates/en-us/mab/Members_life_status.rb
# 
# SASS  ~/megauni/templates/en-us/sass/Members_life.sass
# SASS  ~/megauni/templates/en-us/sass/Members_life_e.sass
# SASS  ~/megauni/templates/en-us/sass/Members_life_qa.sass
# SASS  ~/megauni/templates/en-us/sass/Members_life_status.sass
# 
# CONTROL ~/megauni/controls/Members.rb
#
# NAME  Member_Life


module Base_View_Member_Life

  def life_club_href
    "/life/#{username}/"
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



end # === Base_View_Club
