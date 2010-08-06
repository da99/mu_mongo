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

  def editor_id
    @cache['editor_id'] ||= current_member.username_ids.detect { |id| id == message_owner_id }
  end

  def message
    @app.env['message_by_id']
  end
  
  def message_owner?
    current_member.username_ids.include?(message_owner_id)
  end

  def message_owner_id
    message.data.owner_id
  end

  def message_href
    message.href
  end

  def mess_href
    message_href
  end

  def suggestions_or_answers
    message_question? ? 
      "Answers and Suggestions:" :
      "Suggestions:" 
  end

  def message_question?
    message.data.message_model == 'question'
  end

  def message_answer
    message.data.answer
  end

  def message_id
    message.data._id
  end

  def message_title
    message.data.title || '~ ~ ~ ~'
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

  def message_href_log
    message.href_log
  end

  def message_updator?
    message.updator?(current_member)
  end

  def message_updated?
    !!message.data.updated_at
  end
  
  def message_has_parent?
    message.data.parent_message_id
  end
  
  def message_parent_href
    "/mess/#{message.data.parent_message_id}/"
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

#   def target_ids_joined
#     [message_id, club_id].map(&:to_s).join(",")
#   end

  %w{ questions critiques suggests }.each { |mod|
    eval %~
      def #{mod}
        cache['messages.#{mod}'] ||= compile_messages(message.#{mod}, message.data.as_hash)
      end
    ~
  }

end # === Messages_by_id 
