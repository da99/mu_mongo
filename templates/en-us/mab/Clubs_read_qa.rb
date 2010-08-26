# MODULE templates/en-us/mab/extensions/MAB_Clubs_read_qa.rb
# VIEW ~/megauni/views/Clubs_read_qa.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_qa.sass
# NAME Clubs_read_qa

partial '__club_title'

club_nav_bar(__FILE__)

div_centered do
    
    messages! {
      everybody {
        messages_or_guide
      }
    }

    publish! {
      
      everybody { about }
      
      insider_or_owner {
        post_message
      }
      
    } # === publish!
    
end # div.outer_shell!
    
