# VIEW views/Messages_by_id.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Messages_by_id.sass
# NAME Messages_by_id

div.content! { 
  
  div.message {
   
   mustache 'message' do
  
     div.info {
      span.published_at '{{published_at}}'
      span.starts_at '{{start_at}}'
      span.ends_at '{{ends_at}}'
     }

     h4 '{{title}}'
    
     div.body { 
      '{{{compiled_body}}}' 
     }
     
   end # === mustache 'message'

  } # === div.message
  
  form_create_message %w{
    regular_comment
    tip
    question
  }

  div.tips {
    p 'tips go here'
  }

  div.questions {
    p 'questions go here'
  }

  div.comments {
    p 'comments go here'
  }

} # === div.content!

partial('__nav_bar')

