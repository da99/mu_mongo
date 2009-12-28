# MAB   ~/megauni/templates/English/mab/Club_Cage_hearts.rb
# SASS  ~/megauni/templates/English/sass/Club_Cage_hearts.sass
# NAME  Club_Cage_hearts

class Club_Cage_hearts < Bunny_Mustache

  def title 
    'The Hearts Club'
  end

  def club
    @vars[:club]
  end

  def css_file
    "/stylesheets/English/Club_Cage_#{club.data.filename}.css"
  end
	
end # === Club_Cage_hearts 
