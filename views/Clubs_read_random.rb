# MAB   ~/megauni/templates/en-us/mab/Clubs_read_random.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_random.sass
# NAME  Clubs_read_random

require 'views/extensions/Base_Club'

class Clubs_read_random < Base_View
  
  include Views::Base_Club

  def title 
    return "Random: #{club_title}" unless club.life_club?
    "#{club_filename}'s Random Thoughts & Babble"
  end

  def randoms
    @randoms ||= compile_messages(app.env['results.randoms'])
  end
  
end # === Clubs_read_random 
