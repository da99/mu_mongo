# VIEW views/Messages_by_id.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Messages_by_id.sass
# NAME Messages_by_id

div.content! { 
  
  div.message {

    show_if 'message' do

      div.info {
        span.published_at '{{published_at}}'
      }

      h4 '{{title}}'

      div.body { 
        '{{{compiled_body}}}' 
      }

    end # === show_if 'message'

  } # === div.message
  
  form_create_message %w{ 
    comment 
    tip 
    question 
    cheer 
    complain
  }
  
  div.tips {
    p 'No complaints yet.'
  }

  div.questions {
    p 'No questions.'
  }

  div.cheer {
    p 'No cheer yet.'
  }

  div.complaints {
    p 'No complaints yet.'
  }
  
  
} # === div.content!

partial('__nav_bar')

