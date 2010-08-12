# MAB   ~/megauni/templates/en-us/mab/Clubs_read_thanks.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_thanks.sass
# NAME  Clubs_read_thanks

class Clubs_read_thanks < Base_View

  def title 
    "Thank you for #{club_title}"
  end

  def thanks
    compile_and_cache( 'messages.thanks', app.env['results.thanks'])
  end
  
end # === Clubs_read_thanks 
