# VIEW ~/megauni/views/Clubs_read_fights.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_fights.sass
# NAME Clubs_read_fights

h3.club_title! '{{title}}' 

club_nav_bar(__FILE__)

div.outer_shell! do
  div.inner_shell! do
    
    div.club_body! {
      show_if 'logged_in?' do
        
        div_guide!('Stuff you can do:') {
          p %~
            Express negative feelings. Try to use
          polite profanity, like meathead instead of 
          doo-doo head.
          ~
        }
        
          post_message {
            css_class  'col'
            title      'Publish a new:'
            models     %w{fight complaint debate}
            input_title 
            hidden_input(
              :club_filename => '{{club_filename}}',
              :privacy       => 'public'
            )
          }
        
      end # logged_in?

      div.col.club_messages! do
        
        loop_messages_with_opening(
          'passions',
          'Latest Activity:',
          'Nothing passionate or furious has been published.'
        )
        
      end
      
    } # div.club_body!

  end # div.inner_shell!
end # div.outer_shell!
