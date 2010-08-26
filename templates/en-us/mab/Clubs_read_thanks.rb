# MODULE templates/en-us/mab/extensions/MAB_Clubs_read_thanks.rb
# VIEW ~/megauni/views/Clubs_read_thanks.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_thanks.sass
# NAME Clubs_read_thanks

partial '__club_title'

club_nav_bar(__FILE__)

div_centered {
  
    messages! {
      everybody {
        messages_or_guide
      } 
    }
    
    publish! {
      
      everybody {
        about
      }
      
      insider_or_owner {
        post_message
      }

    } # === publish!


} # === 
