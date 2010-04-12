# VIEW views/Messages_by_id.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Messages_by_id.sass
# NAME Messages_by_id

div.content! { 
  
  div.message {

    mustache 'message' do

      div.info {
        span.published_at '{{published_at}}'
      }

      h4 '{{title}}'

      div.body { 
        '{{{compiled_body}}}' 
      }

    end # === mustache 'message'

  } # === div.message
  
  form_message_create %w{
    regular_comment
    praise
    tip
    question
  }

  div.praise {
    p 'No answers yet.'
  }

  div.questions {
    p 'No questions yet.'
  }

  div.comments {
    p 'No comments.'
  }

  div.tips {
    p 'No questions.'
  }
  
} # === div.content!

partial('__nav_bar')

