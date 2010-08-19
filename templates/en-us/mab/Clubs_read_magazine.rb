# VIEW ~/megauni/views/Clubs_read_magazine.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_magazine.sass
# NAME Clubs_read_magazine

partial '__club_title'

club_nav_bar(__FILE__)

div.outer_shell! do
  div.inner_shell! do
    
    div.club_body! {
      show_if 'logged_in?' do
        
        div_guide!( 'Stuff you can do:' ) {
          ul {
            li 'Write a story.'
            li 'Review a restaurant.'
            li 'Write about a family reunion.'
          }
        }

        post_message {
          css_class'col'
          title  'Publish a new story:'
          input_title 
          hidden_input(
            :message_model => 'mag_story',
            :club_filename => '{{club_filename}}',
            :privacy       => 'public'
          )
        }
        
      end # logged_in?

      div.col.club_messages! do
        
        loop_messages_with_opening(
          'storys',
          'Latest Stories:',
          'Nothing has been posted yet.'
        )
        
      end
      
    } # div.club_body!

  end # div.inner_shell!
end # div.outer_shell!
