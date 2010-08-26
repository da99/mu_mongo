# MODULE templates/en-us/mab/extensions/MAB_Clubs_read_fights.rb
# VIEW ~/megauni/views/Clubs_read_fights.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_fights.sass
# NAME Clubs_read_fights

partial '__club_title'

club_nav_bar(__FILE__)

div_centered do
    
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

end # div_centered
