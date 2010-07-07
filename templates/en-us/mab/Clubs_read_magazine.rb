# VIEW ~/megauni/views/Clubs_read_magazine.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_magazine.sass
# NAME Clubs_read_magazine

h3.club_title! '{{title}}' 

club_nav_bar(__FILE__)

div.outer_shell! do
  div.inner_shell! do
    
    div.club_body! {
      show_if 'logged_in?' do
        
        div.col.guide! {
          h4 'Stuff you can do:'
          ul {
            li 'Write a story. '
            li 'Review a restaurant.'
            li 'Write about a family reunion.'
          }
        }

        div.col.message_create! {
          form_message_create(
            :title => 'Publish a new story:',
            :input_title => true,
            :hidden_input => {
                              :message_model => 'mag_story',
                              :club_filename => '{{club_filename}}',
                              :privacy       => 'public'
                             }
          )
        }
        
      end # logged_in?

      div.col.club_messages! do
        
        show_if('no_storys?'){
          div.empty_msg 'Nothing has been posted yet.'
        }
        
        loop_messages 'storys'
        
      end
      
    } # div.club_body!

  end # div.inner_shell!
end # div.outer_shell!
