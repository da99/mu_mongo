# MAB   ~/megauni/templates/en-us/mab/Clubs_read_shop.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_shop.sass
# NAME  Clubs_read_shop

class Clubs_read_shop < Base_View

  def title 
    return "Shop: #{club_title}" unless club.life_club?
    "#{club_filename}'s Favorite Stuff"
  end

  def no_buys?
    true
  end

  def buys
    cache_and_compile( 'messages.buys', app.env['results.buys'])
  end
  
end # === Clubs_read_shop 
