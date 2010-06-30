# VIEW ~/megauni/views/Clubs_read_thanks.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_thanks.sass
# NAME Clubs_read_thanks

div.col.intro! {
  h3 '{{title}}' 

  show_if 'logged_in?' do
    
    form_message_create(
      :title => 'Post a thank you:',
      :hidden_input => {
                        :message_model => 'thank',
                        :club_filename => '{{club_filename}}',
                        :privacy       => 'public'
                       }
    )
    
  end # logged_in?

} # div.intro!

div.col.navigate! {
  
  club_nav_bar(__FILE__)

  div.club_messages! do
    
    show_if('no_thanks?'){
      div.empty_msg 'No "thank you" has been posted yet.'
    }
    
    loop_messages 'thanks'
    
  end
  
} # div.navigate!

