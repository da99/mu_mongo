# MODULE templates/en-us/mab/extensions/MAB_Clubs_read_shop.rb
# VIEW views/Clubs_read_shop.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_shop.sass
# NAME Clubs_read_shop

partial '__club_title'
club_nav_bar(__FILE__)

div_centered {
  
  messages! {
    loop_messages!
    publisher_guide!
  }
    
  publisher! {
    
    follow!

    stranger {
      about!
    }

    insider_or_owner {
      about!
      post_message!
    }

  } # === publish!

} # === div_centered
