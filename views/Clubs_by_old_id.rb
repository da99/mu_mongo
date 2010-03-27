# MAB   /home/da01tv/MyLife/apps/megauni/templates/English/mab/Clubs_by_old_id.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/English/sass/Clubs_by_old_id.sass
# NAME  Clubs_by_old_id

class Clubs_by_old_id < Base_View

  def title 
    @app.env['results.club']
  end

  def css_file
    "/stylesheets/English/Topic_#{@app.env['results.club']}.css"
  end
  
end # === Clubs_by_old_id 
