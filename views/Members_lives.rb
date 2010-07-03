# MAB   ~/megauni/templates/en-us/mab/Members_lives.rb
# SASS  ~/megauni/templates/en-us/sass/Members_lives.sass
# NAME  Members_lives

class Members_lives < Base_View

  def title 
    current_member_username
  end

	def current_member_username
		app.env['results.username']
	end

  def newspaper
    cache_and_compile( 'messages.newspaper', app.current_member.newspaper(current_member_username) )
  end

  def newspaper?
    newspaper.size > 0
  end
  
end # === Members_lives 
