# MAB   ~/megauni/templates/en-us/mab/Clubs_read_fights.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_fights.sass
# NAME  Clubs_read_fights

class Clubs_read_fights < Base_View

  def title 
    "#{club_title} Fights"
  end

  def passions
    compile_and_cache( 'messages.passions' , app.env['results.passions'])
  end
  
end # === Clubs_read_fights 
