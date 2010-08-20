# VIEW ~/megauni/views/Clubs_read_e.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME Clubs_read_e
# 
# Life/Club Encyclopedia
#   COL 0: messages!
#     - MESSAGES
#       - EMPTY?
#         - Tell me what I should do.
#     
#   - OWNER?
#     COL 1: publish!
#       - ABOUT THIS Encyclopedia
#       - PUBLISH MESSAGE
# 
#   - AUDIENCE?
#     COL 1: publish!
#     - FOLLOW/UNFOLLOW this encyclopedia
#     - ABOUT THIS Encyclopedia
#     - PUBLISH MESSAGE
#     

partial '__club_title'

club_nav_bar(__FILE__)

div_centered {
    
  div.col.messages! {
    
    loop_messages_with_opening 'quotes', 'Quotations'
    loop_messages_with_opening 'chapters', 'Chapters'
    
    if_not('quotes_or_chapters?'){
      show_if 'owner?' do
        guide!('Stuff you can do:') {
          ul {
            li 'Write a story. '
            li 'Post a quotation.'
            li 'Tell others of related links.'
          }
        }
      end
    }
    
  } # === messages!

  publish! {
    follow!
    about!
    post_message!
  }


} # === div_centered

