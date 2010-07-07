# VIEW ~/megauni/views/Clubs_read_thanks.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_thanks.sass
# NAME Clubs_read_thanks

h3.club_title! '{{title}}' 

club_nav_bar(__FILE__)

div.outer_shell! do
  div.inner_shell! do
    
    div.club_body! {

      show_if 'logged_in?' do
        
        div.col.guide! {
          h4 'Stuff you can do here:'
          p %~
            Show how this club or it's members 
          have made your life better.
          ~
        }
        
        div.col.message_create! {
          form_message_create(
            :title => 'Post a thank you:',
            :hidden_input => {
                              :message_model => 'thank',
                              :club_filename => '{{club_filename}}',
                              :privacy       => 'public'
                             }
          )
        }
        
      end # logged_in?

      div.col.club_messages! do
        
        show_if('no_thanks?'){
          div.empty_msg 'Nothing has been posted yet.'
        }
        
        loop_messages 'thanks'
        
      end
      
    } # div.navigate!

  end # div.inner_shell!
end # div.outer_shell!

