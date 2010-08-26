# MODULE templates/en-us/mab/extensions/MAB_Clubs_read_magazine.rb
# VIEW ~/megauni/views/Clubs_read_magazine.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_magazine.sass
# NAME Clubs_read_magazine

partial '__club_title'

club_nav_bar(__FILE__)

div_centered do
    
  messages! {
    messages_or_guide
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

end # div.outer_shell!
