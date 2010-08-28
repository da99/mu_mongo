# MODULE templates/en-us/mab/extensions/MAB_Clubs_by_filename.rb
# VIEW ~/megauni/views/Clubs_by_filename.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_by_filename.sass
# NAME Club_by_filename
# 

div.pretension! {
  partial '__club_title'
  everybody {
    about
  }
  club_nav_bar(__FILE__)
}

  
div.the_rest! do
    
  messages! {
    everybody {
      messages_or_guide
    }
  }

  about! {
    
    # stranger {
    #   about
    # }
    
    member_or_insider {
      follow
      # about
    }
    
    owner {
      not_life? {
        follow
      }
      # about
      edit!
    }
    
  } # === about!

  memberships! {
    
    stranger {
      memberships
    }
    
    member_or_insider {
      memberships
      post_membership_plea
    }
    
    owner {
      memberships_guide!
      memberships
      post_membership!
    }
    
  } # === publish!
  
end # === div_centered
