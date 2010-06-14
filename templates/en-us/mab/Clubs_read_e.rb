# VIEW ~/megauni/views/Clubs_read_e.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME Clubs_read_e

div.col.intro! {
  h3 'Encyclopedia: {{club_title}}' 

  show_if 'logged_in?' do
    
    form_message_create(
      :title => 'Post a new section:',
      :hidden_input => {
                        :message_model => 'fact',
                        :club_filename => '{{club_filename}}',
                        :privacy       => 'public'
                       }
    )
    
  end # logged_in?

} # div.intro!

div.col.navigate! {
  
  club_nav_bar(__FILE__)

  div.club_messages! do
    
    show_if('no_facts'){
      div.empty_msg 'Nothing has been posted yet.'
    }
    
    loop_messages 'facts'
    
  end
  
} # div.navigate!

