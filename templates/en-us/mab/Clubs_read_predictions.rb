# VIEW views/Clubs_read_predictions.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_predictions.sass
# NAME Clubs_read_predictions

div.col.intro! {
  
  h3 '{{title}}' 
  
  show_if 'logged_in?' do
    
    form_message_create(
      :title => 'Post a prediction:',
      :hidden_input => {
                        :message_model => 'prediction', 
                        :club_filename => '{{club_filename}}',
                        :privacy       => 'public'
                       }
    )
    
  end # logged_in?

} # div.intro!

div.col.navigate! {
  
  club_nav_bar(__FILE__)

  div.club_messages! do
    
    show_if('no_predictions?'){
      div.empty_msg 'Nothing has been posted yet.'
    }
    
    loop_messages 'predictions'
    
  end

} # div.navigate!
