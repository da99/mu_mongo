# MAB   /home/da01tv/MyLife/apps/megauni/templates/en-us/mab/Members_life.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Members_life.sass
# NAME  Members_life

class Members_life < Base_View

  def title 
    "The Life of #{@app.env['results.username']}"
  end
  
end # === Members_life 
