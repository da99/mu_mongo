# MAB   ~/megauni/templates/en-us/mab/Clubs_read_qa.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_qa.sass
# NAME  Clubs_read_qa

require 'views/__Base_View_Club'

class Clubs_read_qa < Base_View
 
  include Base_View_Club

  def title 
    "Q & A: #{super}"
  end
  
end # === Clubs_read_qa 
