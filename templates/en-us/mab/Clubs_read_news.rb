# VIEW views/Clubs_read_news.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Clubs_read_news.sass
# NAME Clubs_read_news

h3 'News: {{club_title}}' 

div.teaser '{{club_teaser}}'

club_nav_bar(__FILE__)

show_if 'logged_in?' do
  
  form_message_create(
    :title => 'Post news:',
    :hidden_input => Hash.new[
                      :message_model => 'news', 
                      :club_filename => '{{club_filename}}',
                      :privacy       => 'public'
                     ]
  )
  
end # logged_in?


div.club_messages! do
  
  show_if('no_messages'){
    div.empty_msg 'Nothing has been posted yet.'
  }
  
  loop_messages 'messages'
  
end

