# MODULE templates/en-us/mab/extensions/MAB_Clubs_by_filename.rb
# VIEW ~/megauni/views/Clubs_by_filename.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_by_filename.sass
# NAME Club_by_filename
# 
# Life/Club Homepage
#   COL 0: messages!
#     - MESSAGES
#       - EMPTY?
#         - Tell me what I should do.
#     
#   - OWNER?
#     COL 1: publish!
#       - ABOUT THIS LIFE
#       - EDIT LIFE
#       - MEMBERS_LIST
#         - What can you do with this.
#         - ADD MORE W/ TEXTAREA
# 
#   - AUDIENCE?
#     COL 1: publish!
#     - FOLLOW/UNFOLLOW
#     - ABOUT THIS LIFE
#     - SUBMIT MEMBERSHIP PLEA (if applications allowed)
#     

partial '__club_title'

club_nav_bar(__FILE__)

div_centered do
    
  messages! {
    loop_messages!
    publisher_guide!
  }

  publish! {
    
    follow!
    
    stranger! {
      about!
      memberships!
    }
    
    member_or_insider! {
      about!
      post_membership_plea!
    }
    
    owner! {
      about!
      edit!
      memberships_guide!
      memberships!
      post_membership!
    }
    
  } # === publish!
  
end # === div_centered
