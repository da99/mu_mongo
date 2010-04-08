# MAB   /home/da01tv/MyLife/apps/megauni/templates/en-us/mab/Messages_by_id.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Messages_by_id.sass
# NAME  Messages_by_id

class Messages_by_id < Base_View

  def from_surfer_hearts?
    message.data.created_at < '2010-01-01 01:01:01'
  end

  def title 
    message.data.title || message.data._id.to_s.sub('message-', 'Message ID: ')
  end

  def published_at
    message.published_at.strftime('%b  %d, %Y')
  end

  def message
    @app.env['message_by_id']
  end

  def message_data
    @cache[:message_data] ||= begin
                                v= message.data.as_hash
                                v[:compiled_body] = from_surfer_hearts? ? v['body'] : auto_link(v['body'])
                                v
                              end
  end

  
end # === Messages_by_id 
