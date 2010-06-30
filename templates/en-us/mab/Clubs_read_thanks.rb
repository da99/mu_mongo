# VIEW ~/megauni/views/Clubs_read_thanks.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_thanks.sass
# NAME Clubs_read_thanks

# div.col.intro! {
# } # div.intro!

div.col.navigate! {
  
  h3 '{{title}}' 
  
  club_nav_bar(__FILE__)

  show_if 'logged_in?' do
    
    div.guide! {
      h4 'Stuff you can do here:'
      p %~
        Show how this club or it's members 
      have made your life better.
      ~
    }
    
    form_message_create(
      :title => 'Post a thank you:',
      :hidden_input => {
                        :message_model => 'thank',
                        :club_filename => '{{club_filename}}',
                        :privacy       => 'public'
                       }
    )
    
  end # logged_in?

  div.club_messages! do
    
    show_if('no_thanks?'){
      div.empty_msg 'Nothing has been posted yet.'
    }
    
    loop_messages 'thanks'
    
  end
  
} # div.navigate!

