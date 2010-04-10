# MAB   /home/da01tv/MyLife/apps/megauni/templates/en-us/mab/Messages_by_id.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Messages_by_id.sass
# NAME  Messages_by_id

class Messages_by_id < Base_View

  def show_moving_message?
    from_surfer_hearts?(message.data.as_hash)
  end

  def product?
    message.product?
  end

  def title 
    message.data.title || 
      (message.data.as_hash.has_key?('old_id') && message.data._id.to_s.sub('message-', 'Message ID: ')) ||
        ( "Message ID: #{message.data._id}" )
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
                                v[:compiled_body] = from_surfer_hearts?(v) ? v['body'] : auto_link(v['body'])
                                v
                              end
  end

  
end # === Messages_by_id 
