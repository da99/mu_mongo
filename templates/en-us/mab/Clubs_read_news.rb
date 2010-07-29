# VIEW views/Clubs_read_news.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Clubs_read_news.sass
# NAME Clubs_read_news

h3.club_title! '{{title}}' 

club_nav_bar(__FILE__)

div.outer_shell! do
  div.inner_shell! do
    
    div.club_body! {
      
      show_if 'logged_in?' do
        
        div_guide!( 'Stuff you can do here:' ) {
          p %~
            Post only important news. 
          Examples:
          ~
          ul {
            li 'Your plane landed in Dallas.'
            li 'You got a job demotion.'
            li 'You broke up with your dog walker.'
            li 'You got arrested... again.'
          }
        }

          form_message_create(
            :css_class => 'col',
            :title => 'Post news:',
            :input_title => true,
            :hidden_input => {
                              :message_model => 'news', 
                              :club_filename => '{{club_filename}}',
                              :privacy       => 'public'
                             }
          )
        
      end # logged_in?


      div.col.club_messages! do
        
        loop_messages_with_opening(
          'news',
          'Latest News:',
          'Nothing has been posted yet.'
        )

      end

    } # div.club_body!
    
  end # div.inner_shell!
end # div.outer_shell!
