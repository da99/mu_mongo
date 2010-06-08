# MAB   ~/megauni/templates/en-us/mab/Clubs_read_e.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME  Clubs_read_e

require 'views/__Base_View_Club'

class Clubs_read_e < Base_View
 
  include Base_View_Club

  def title 
    "Encyclopedia: #{super}"
  end

  def messages
    nil
  end
  
end # === Clubs_read_e 
