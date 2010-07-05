# MAB   ~/megauni/templates/en-us/mab/Messages_by_id.rb
# SASS  ~/megauni/templates/en-us/sass/Messages_by_id.sass
# NAME  Messages_by_id

class Messages_by_id < Base_View

  def show_form_create_message?
    logged_in?
  end

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

  def message_model
    message.data.message_model
  end

  def message_model_in_english
    message.message_model_in_english
  end

  def message_section
    message.message_section
  end

  def message_section_href
    suffix = case message_section
      when Message::SECTIONS::E
        'e'
      when Message::SECTIONS::QA
        'qa'
      else
        message_section.to_s.downcase.split.join('_')
      end
    File.join(club_href, suffix + '/')
  end

  def message_data
    cache[:message_data] ||= begin
                                v= message.data.as_hash
                                v[:compiled_body] = from_surfer_hearts?(v) ? v['body'] : auto_link(v['body'])
                                v
                              end
  end

  def message_href_edit
    message.href_edit
  end

  def message_updator?
    message.updator?(current_member)
  end

  def club
    message.club
  end

  def club_title
    club.data.title
  end

  def club_href
		club.href
  end

  def target_ids_joined
    [club.data._id].map(&:to_s).join(",")
  end

  def questions
    cache['messages.questions'] ||= compile_messages(Message.latest_questions_by_club_id(club_id))
  end

  def comments
    cache['messages.comments'] ||= compile_messages(Message.latest_comments_by_club_id(club_id))
  end
  
end # === Messages_by_id 
