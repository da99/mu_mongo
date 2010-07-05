# MAB   ~/megauni/templates/en-us/mab/Clubs_read_magazine.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_magazine.sass
# NAME  Clubs_read_magazine

class Clubs_read_magazine < Base_View

  def title 
    "Magazine: #{club_title}"
  end

  def storys
    compile_and_cache('messages.storys' , app.env['results.magazine'])
  end
  
end # === Clubs_read_magazine 
