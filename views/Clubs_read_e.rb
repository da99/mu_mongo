# MAB   ~/megauni/templates/en-us/mab/Clubs_read_e.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME  Clubs_read_e

class Clubs_read_e < Base_View
 
  def title 
    return "Encyclopedia: #{club_title}" unless club.life_club?
    "The Encyclopedia of #{club_filename}"
  end

  def facts
    cache_and_compile( 'messages.facts',  app.env['results.facts'] )
  end
  
end # === Clubs_read_e 
