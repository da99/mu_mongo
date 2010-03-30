# MAB   /home/da01tv/MyLife/apps/megauni/templates/English/mab/Members_lives.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/English/sass/Members_lives.sass
# NAME  Members_lives

class Members_lives < Base_View

  def title 
    current_member_username
  end

	def current_member_username
		@app.env['results.username']
	end
  
end # === Members_lives 
