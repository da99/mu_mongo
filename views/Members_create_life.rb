# MAB   /home/da01tv/MyLife/apps/megauni/templates/en-us/mab/Members_create_life.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Members_create_life.sass
# NAME  Members_create_life

class Members_create_life < Base_View

  def title 
    'Add username.'
  end

  def session_form_username
    @app.clean_room[:add_username]
  end
  
end # === Members_create_life 
