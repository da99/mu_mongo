# MAB   ~/megauni/templates/en-us/mab/Clubs_read_random.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_random.sass
# NAME  Clubs_read_random

class Clubs_read_random < Base_View

  def title 
    return "Random: #{club_title}" unless club.life_club?
    "#{club_filename}'s Random Thoughts & Babble"
  end

  def random
    @cache['results.randoms'] ||= compile_messages(app.env['results.randoms'])
  end
  
end # === Clubs_read_random 
