# VIEW ~/megauni/views/Clubs_by_id.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_by_id.sass
# NAME Club_profile

div.col.intro! {
  
  h3 '{{club_title}}' 

  div.teaser '{{club_teaser}}'

  
  show_if 'logged_in?' do
    
    form_message_create(
      :hidden_input => { :club_filename => '{{club_filename}}',
                         :privacy       => 'public'
                       }
    )
    
  end # logged_in?

} # div.intro!


div.col.navigate! {
  
  club_nav_bar(__FILE__)


  div.club_messages! do
    
    show_if('no_messages_latest?'){
      div.empty_msg 'No messages yet.'
    }
    
    loop_messages 'messages_latest'
    
  end
  
} # div.navigate!

