# MAB   ~/megauni/templates/en-us/mab/Clubs_list.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_list.sass
# NAME  Clubs_list

class Clubs_list < Base_View

  def title 
    'Full list of clubs.'
  end

  def clubs
    cache('clubs') ||
      cache_and_compile( 'clubs', @app.env['results.clubs'] ) 
  end

  def other_clubs
    cache('clubs.other') || 
      cache_and_compile( 'clubs.other',  (clubs - your_clubs) )
  end

end # === Clubs_list 
