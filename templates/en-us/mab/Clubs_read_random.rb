# VIEW views/Clubs_read_random.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_random.sass
# NAME Clubs_read_random

partial '__club_title'

club_nav_bar(__FILE__)

div.outer_shell! do
  div.inner_shell! do
    
    div.club_body! {
      
      show_if 'logged_in?' do
        
        div_guide!( 'Stuff you can do here:' ) {
          p %~
            Post stuff that no one really 
          cares about. Examples:
          ~
          ul {
            li 'Thoughts on economics.'
            li 'Opinions on religion.'
            li 'Wonder why the world is against you.'
          }
        }

          post_message {
            css_class  'col'
            title  'Post a random thought:'
            input_title 
            hidden_input(
              :message_model => 'random',
              :club_filename => '{{club_filename}}',
              :privacy       => 'public'
            )
          }
        
      end # logged_in?

      div.col.club_messages! do
        
        loop_messages_with_opening(
          'random',
          'Latest Random Thoughts:',
          'Nothing has been posted yet.'
        )
        
      end

    } # div.navigate!
    
  end # div.inner_shell!
end # div.outer_shell!
