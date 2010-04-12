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
  
  form_create_message %w{ 
    comment 
    tip 
    question 
    praise 
    complain
  }
  
  div.tips {
    p 'No complaints yet.'
  }

  div.questions {
    p 'No questions.'
  }

  div.praise {
    p 'No praise yet.'
  }

  div.complaints {
    p 'No complaints yet.'
  }
  
  
} # === div.content!

partial('__nav_bar')

