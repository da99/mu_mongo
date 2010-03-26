# MAB   /home/da01tv/MyLife/apps/megauni/templates/English/mab/Messages_by_id.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/English/sass/Messages_by_id.sass
# NAME  Messages_by_id

class Messages_by_id < Base_View

  def title 
    message.data.title
  end

  def published_at
    message.published_at.strftime('%b  %d, %Y')
  end

  def message
    @app.env['message_by_id']
  end

  def message_data
    message.data
  end

  
end # === Messages_by_id 
