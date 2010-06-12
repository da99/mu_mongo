# MAB   ~/megauni/templates/en-us/mab/Clubs_club_search.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_club_search.sass
# NAME  Clubs_club_search

require 'views/__Base_View_Club'

class Clubs_club_search < Base_View

	include Base_View_Club

  def title 
    "Club not found: #{club_filename}"
  end

	def clubs
		@cache['clubs'] ||= compile_clubs(Club.all) + old_clubs
	end

	def club_filename
		app.env['club_filename']
	end
  
end # === Clubs_club_search 
