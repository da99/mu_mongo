# VIEW ~/megauni/views/Clubs_by_filename.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_by_filename.sass
# NAME Club_by_filename

partial '__club_title'

club_nav_bar(__FILE__)

div_centered do
    

    show_if 'logged_in?' do
      show_if 'memberships?' do
        ul {
          loop 'memberships' do
            li { a! "Withdraw as: name.m", 'href' }
          end
        }
      end
      show_if 'follower_but_not_owner?' do
        delete_form 'follow' do
          action 'href_delete_follow'.m!
          submit {
            a_click 'Unfollow'
          }
        end
      end
      show_if 'notifys?' do
        a! 'See all notifys.', 'href_notifys'
      end
    end # === logged_in?
  
    div.col.intro! {
      
      mustache 'owner?' do
      
        div.section.controls_list! {
          h3 'You own this universe:'
          a_button! 'Members list.', 'href_members' 
          a_button! 'Edit settings.', 'href_edit'   
        }
        
        show_if 'follows?' do
          div.section.follows_list! {
            h3 'You are following:'
            ul {
              loop 'follows' do
                li { a! 'title', 'href'  }
              end
            }
          } # === div.follows_list!
        end
        
      end # === owner?

      club_follow_guide
      
      div.section.about! {
        h3 'About this universe:'
        div.teaser '{{club_teaser}}'
      }
      
      div_guide 'Stuff you should do:' do
        ul {
          li "Post something in the \"Encyclopedia\" section."
          li "Write anything in the \"Random\" section."
          li %~ Recommend a product in the "Shop" section. ~
          li %~ Ask a question in the "Q & A" section. ~
        }
      end

    } # div.intro!

    div.col.messages! {
      
      show_if('no_messages_latest?'){
        div.empty_msg 'No messages yet.'
      }
      
      show_if 'messages_latest?' do
        loop_messages 'messages_latest' 
      end
      
    } # === messages!
      
end # div_centered
