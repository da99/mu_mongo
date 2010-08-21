# MODULE templates/en-us/mab/extensions/MAB_Clubs_read_e.rb
# VIEW ~/megauni/views/Clubs_read_e.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME Clubs_read_e
# 

partial '__club_title'

club_nav_bar(__FILE__)

div_centered {
    
  messages! {
    
    loop_messages_with_opening 'quotes', 'Quotations'
    loop_messages_with_opening 'chapters', 'Chapters'
    publisher_guide!
    
  } # === messages!

  publish! {
    
    stranger {
      follow!
      about
    }
    
    member {
      follow!
    }

    insider {
      follow!
      about
      post_message!
    }
      
    owner {
      club {
        follow!
      }
      about
      post_message!
    }
    
  } # === publish!


} # === div_centered

