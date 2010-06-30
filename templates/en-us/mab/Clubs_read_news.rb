# VIEW views/Clubs_read_news.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Clubs_read_news.sass
# NAME Clubs_read_news

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
        Post only important news. 
      Examples:
      ~
      ul {
        li 'Your plane landed in Dallas.'
        li 'You got a job demotion.'
        li 'You broke up with your dog walker.'
        li 'You got arrested... again.'
      }
    }

    form_message_create(
      :title => 'Post news:',
      :hidden_input => {
                        :message_model => 'news', 
                        :club_filename => '{{club_filename}}',
                        :privacy       => 'public'
                       }
    )
    
  end # logged_in?


  div.club_messages! do
    
    show_if('no_news?'){
      div.empty_msg 'Nothing has been posted yet.'
    }
    
    loop_messages 'news'
    
  end

} # div.navigate!
