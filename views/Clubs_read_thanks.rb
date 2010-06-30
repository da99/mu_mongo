# MAB   ~/megauni/templates/en-us/mab/Clubs_read_thanks.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_thanks.sass
# NAME  Clubs_read_thanks

class Clubs_read_thanks < Base_View

  def title 
    "Thank you, #{club_title}"
  end

	def thanks
		@cache['results.thanks'] ||= compile_messages(app.env['results.thanks'])
	end
  
end # === Clubs_read_thanks 
