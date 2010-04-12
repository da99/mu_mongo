# VIEW views/Messages_by_id.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Messages_by_id.sass
# NAME Messages_by_id

div.content! { 
  
  div.message {
   
   div.info {
    span.published_at '{{published_at}}'
   }

   mustache 'message' do
     h4 '{{title}}'
     div.body { '{{{compiled_body}}}' }
   end


  } # === div.message
  
  form_create_message %w{
    regular_comment
    praise
    complain
    tip
    question
  }
     
  div.praise {
    p 'praise goes here'
  }

  div.complain {
    p 'complaints go here'
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

