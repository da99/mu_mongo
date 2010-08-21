# MODULE templates/en-us/mab/extensions/MAB_Clubs_read_random.rb
# VIEW views/Clubs_read_random.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_random.sass
# NAME Clubs_read_random

partial '__club_title'

club_nav_bar(__FILE__)

div_centered {
  
  messages! {
    loop_messages!
    publisher_guide!
  }

  publish! {
    
    follow!

    stranger {
      about
    }
    
    insider_or_owner {
      about
      post_message!
    }
    
  } # === publish
        
} # === div_centered
