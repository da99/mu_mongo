# VIEW views/Messages_by_id.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Messages_by_id.sass
# NAME Messages_by_id

div.content! { 
  
  div.message do
   
   div.info {
    span.published_at '{{published_at}}'
   }

   mustache 'message' do
     h4 '{{title}}'
     div.body { 
      '{{{compiled_body}}}' 
     }
   end

  end # div.message
  
  form_create_message %w{
    regular_comment
    idea
    question
  }

  div.ideas {
    p 'ideas go here'
  }

  div.comments {
    p 'comments go here'
  }

  div.questions {
    p 'No questions yet.'
  }
  
} # === div.content!

partial('__nav_bar')

