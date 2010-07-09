# VIEW views/Clubs_read_random.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_random.sass
# NAME Clubs_read_random

h3.club_title! '{{title}}' 

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

          form_message_create(
          :css_class => 'col',
            :title => 'Post a random thought:',
            :hidden_input => {
                              :message_model => 'random',
                              :club_filename => '{{club_filename}}',
                              :privacy       => 'public'
                             }
          )
        
      end # logged_in?

      div.col.club_messages! do
        
        show_if('no_random?'){
          div.empty_msg 'Nothing has been posted yet.'
        }
        
        loop_messages 'random'
        
      end

    } # div.navigate!
    
  end # div.inner_shell!
end # div.outer_shell!
