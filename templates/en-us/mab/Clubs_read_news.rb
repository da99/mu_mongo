# VIEW views/Clubs_read_news.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Clubs_read_news.sass
# NAME Clubs_read_news

div.col.intro! {
  
  h3 '{{title}}' 
  
  show_if 'logged_in?' do
    
    form_message_create(
      :title => 'Post news:',
      :hidden_input => {
                        :message_model => 'news', 
                        :club_filename => '{{club_filename}}',
                        :privacy       => 'public'
                       }
    )
    
  end # logged_in?

} # div.intro!

div.col.navigate! {
  
  club_nav_bar(__FILE__)

  div.club_messages! do
    
    show_if('no_news?'){
      div.empty_msg 'Nothing has been posted yet.'
    }
    
    loop_messages 'news'
    
  end

} # div.navigate!
