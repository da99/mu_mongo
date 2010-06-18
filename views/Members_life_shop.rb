# MAB   ~/megauni/templates/en-us/mab/Members_life_shop.rb
# SASS  ~/megauni/templates/en-us/sass/Members_life_shop.sass
# NAME  Members_life_shop

require 'views/__Base_View_Member_Life'

class Members_life_shop < Base_View

  include Base_View_Member_Life

  def title 
    "#{username}'s Shop"
  end

  def buys
    compiled_owner_messages 'shop'
  end
  
end # === Members_life_shop 
