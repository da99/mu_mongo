# MODULE templates/en-us/mab/extensions/MAB_Clubs_read_news.rb
# VIEW views/Clubs_read_news.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Clubs_read_news.sass
# NAME Clubs_read_news

partial '__club_title'

club_nav_bar(__FILE__)

div_centered {
    
    messages! {
      everybody {
        messages_or_guide
      }
    }
    
    publish! {
      
      stranger {
        about
      }
      
      insider_or_owner {
        about
        post_message
      }
      
    } # === publish!
      
} # === div_centered
