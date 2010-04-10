# MAB   /home/da01/MyLife/apps/megauni/templates/en-us/mab/Members_today.rb
# SASS  /home/da01/MyLife/apps/megauni/templates/en-us/sass/Member_Control_today.sass
# NAME  Members_today

class Members_today < Base_View

  def title 
    'Today on '
  end

  def newspaper
    @cache[:newspaper] ||= compile_messages( current_member.newspaper )
  end
	
  def clubs
    @cache[:clubs] ||= current_member.potential_clubs
  end

end # === Member_Control_today 
