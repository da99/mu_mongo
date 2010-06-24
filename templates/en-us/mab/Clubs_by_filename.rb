# VIEW ~/megauni/views/Clubs_by_filename.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_by_filename.sass
# NAME Club_by_filename


div.col.intro! {
  
  h3 '{{club_title}}' 

  div.teaser '{{club_teaser}}'

  show_if 'logged_in?' do
    
    show_if('club_updator?') {
      div {
        a('Edit settings.', :href=>'{{club_href_edit}}')
      }
    }

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

