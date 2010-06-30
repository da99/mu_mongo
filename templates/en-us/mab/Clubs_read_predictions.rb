# VIEW views/Clubs_read_predictions.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_predictions.sass
# NAME Clubs_read_predictions

# div.col.intro! {
#   
# } # div.intro!

div.col.navigate! {
  
  h3 '{{title}}' 
  
  club_nav_bar(__FILE__)

  show_if 'logged_in?' do
    
    div.guide! {
      h4 'Stuff you can do here:'
      p %~
        This is where you can publish your thoughts
      on what will happen in the future.  When
      you are right, you can yell, "I told you so!"
      ~
    }

    form_message_create(
      :title => 'Post a prediction:',
      :hidden_input => {
                        :message_model => 'prediction', 
                        :club_filename => '{{club_filename}}',
                        :privacy       => 'public'
                       }
    )
    
  end # logged_in?

  div.club_messages! do
    
    show_if('no_predictions?'){
      div.empty_msg 'Nothing has been posted yet.'
    }
    
    loop_messages 'predictions'
    
  end

} # div.navigate!
