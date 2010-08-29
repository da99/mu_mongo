# MODULE templates/en-us/mab/extensions/MAB_Clubs_read_e.rb
# VIEW ~/megauni/views/Clubs_read_e.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME Clubs_read_e
# 

club_nav_bar(__FILE__)
  
div.pretension! {
  partial '__club_title'
  everybody {
    about
  }
}

div.the_rest! {
    
  messages! {
    
    everybody {
      messages_or_guide    
    }  
    
  } # === messages!

  publish! {
    
    insider_or_owner {
      post_message
    }
    
  } # === publish!

} # === div_centered

