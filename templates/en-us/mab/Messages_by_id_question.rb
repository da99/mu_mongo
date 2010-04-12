# VIEW views/Messages_by_id.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Messages_by_id.sass
# NAME Messages_by_id

div.content! { 
  
  div.message {

    mustache 'message' do

      div.info {
        span.published_at '{{published_at}}'
      }

      div.body { 
        '{{{compiled_body}}}' 
      }

    end # === mustache 'message'

  } # === div.message
  
  form_message_create %w{
    comment
    answer
    question
  }

  div.answers {
    p 'No answers yet.'
  }

  div.questions {
    p 'No questions.'
  }

  div.comments {
    p 'No comments.'
  }

} # === div.content!

partial('__nav_bar')

