# VIEW views/Messages_by_id.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Messages_by_id.sass
# NAME Messages_by_id

div.content! { 
  
  show_if 'show_moving_message?' do
    div.notice! {
      span "I'm moving content from my old site, "
      a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
      span ", over to this new site."
    }
  end
  
  div.heart_link.news_post {
   
   div.info {
    span.published_at '{{published_at}}'
   }

   show_if 'message_data' do
     h4 '{{title}}'
     div.body { '{{{compiled_body}}}' }
   end

   show_if 'product?' do
     
     div.wonderful {
      p '---'
     }

     div.tips {
       p '---'
     }

     div.questions {
       p '---'
     }

     div.complain {
       p '---'
     }

   end
  }
  
  show_if 'show_moving_message?' do
    div.news_post.archives! {
      h4 'Archives:'
      div.body {
      
        a('See all.', :href=>'/clubs/hearts/')
        
      }
    }
  end
} # === div.content!

partial('__nav_bar')

