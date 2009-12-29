# MAB   ~/megauni/templates/English/mab/Club_Control_hearts.rb
# SASS  ~/megauni/templates/English/sass/Club_Control_hearts.sass
# NAME  Club_Control_hearts

class Club_Control_hearts < Base_View

  def title 
    'The Hearts Club'
  end

  def club
    @app.env['the.app.club']
  end

end # === Club_Control_hearts 
