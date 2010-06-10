# VIEW ~/megauni/views/Clubs_read_e.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME Clubs_read_e

h3 'Encyclopedia: {{club_title}}' 

div.teaser '{{club_teaser}}'

club_nav_bar(__FILE__)

show_if 'logged_in?' do
  
  form_message_create(
    :title => 'Post a new section:',
    :hidden_input => Hash.new[
                      :message_model => 'fact',
                      :club_filename => '{{club_filename}}',
                      :privacy       => 'public'
                     ]
  )
  
end # logged_in?


div.club_messages! do
  
  show_if('no_facts'){
    div.empty_msg 'Nothing has been posted yet.'
  }
  
  loop_messages 'facts'
  
end

