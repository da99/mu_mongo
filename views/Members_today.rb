# MAB   /home/da01/MyLife/apps/megauni/templates/en-us/mab/Members_today.rb
# SASS  /home/da01/MyLife/apps/megauni/templates/en-us/sass/Member_Control_today.sass
# NAME  Members_today

class Members_today < Base_View
  
  def title 
    "Today on #{site_title}"
  end

  def stream
    return []
    @cache_clubs_stream ||= compile_clubs(current_member.stream)
  end

  def random_stream
    @cache_messages_random_stream ||= compile_messages(Club.random_stream)
  end

  def my_club_href
    "/life/#{current_member.usernames.first}/"
  end

end # === Member_Control_today 
