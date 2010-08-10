# VIEW views/Clubs_read_predictions.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_predictions.sass
# NAME Clubs_read_predictions

h3.club_title! '{{title}}' 

club_nav_bar(__FILE__)

div.outer_shell! do
  div.inner_shell! do
    
    div.club_body! {

      show_if 'logged_in?' do
        
        div_guide!( 'Stuff you can do here:' ) {
          p %~
            This is where you can publish your thoughts
          on what will happen in the future.  When
          you are right, you can yell, "I told you so!"
          ~
        }

          post_message {
            css_class  'col'
            title  'Post a prediction:'
            hidden_input(
              :message_model => 'prediction', 
              :club_filename => '{{club_filename}}',
              :privacy       => 'public'
            )
          }
        
      end # logged_in?

      div.col.club_messages! do
        
        loop_messages_with_opening(
          'predictions',
          'Latest Predictions:',
          'Nothing has been posted yet.'
        )

      end

    } # div.navigate!
    
  end # div.inner_shell!
end # div.outer_shell!

