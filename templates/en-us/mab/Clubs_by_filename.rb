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
    
    div.col.messages! {
      
      loop_messages 'messages_latest' 
      
      if_empty('messages_latest'){
        show_if 'owner?' do
          guide!('Stuff you should do:') {
            ul {
              li "Post something in the \"Encyclopedia\" section."
              li "Write anything in the \"Random\" section."
              li %~ Recommend a product in the "Shop" section. ~
              li %~ Ask a question in the "Q & A" section. ~
            }
          }
        end
      }
      
    } # === messages!

    div.col.publish! {
      
      follow!
      about!
      edit!
      memberships!
      
    } # === div.publish!
    
end # === div_centered
