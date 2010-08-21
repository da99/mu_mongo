# MODULE templates/en-us/mab/extensions/MAB_Clubs_by_filename.rb
# VIEW ~/megauni/views/Clubs_by_filename.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_by_filename.sass
# NAME Club_by_filename
# 

partial '__club_title'

club_nav_bar(__FILE__)

div_centered do
    
  messages! {
    loop_messages!
    publisher_guide!
  }

  about! {
    
    stranger {
      follow!
      about
    }
    
    member_or_insider {
      follow!
      about
    }
    
    owner {
      club {
        follow!
      }
      about
      edit!
    }
    
  } # === about!

  memberships! {
    
    stranger {
      memberships
    }
    
    member_or_insider {
      memberships
      post_membership_plea!
    }
    
    owner {
      memberships_guide!
      memberships
      post_membership!
    }
    
  } # === publish!
  
end # === div_centered
