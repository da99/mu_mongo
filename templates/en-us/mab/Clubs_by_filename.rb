# VIEW ~/megauni/views/Clubs_by_filename.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_by_filename.sass
# NAME Club_by_filename


h3.club_title! '{{club_title}}' 

club_nav_bar(__FILE__)

div.outer_shell! do
  
  div.inner_shell! do
    
    div.club_body! {

      show_if 'logged_in?' do
        show_if 'memberships?' do
          ul {
            loop 'memberships' do
              li { a! "Withdraw as: {{name}}", 'href'.m! }
            end
          }
        end
        show_if 'follower_but_not_owner?' do
          post_delete 'follow' do
            action 'href_delete_follow'.m!
            submit {
              a_click 'Unfollow'
            }
          end
        end
        show_if 'notifys?' do
          a! 'See all notifys.', 'href_notifys'
        end
      end
    
      div.col.intro! {

        h4 'About this universe:'
        
        mustache 'owner?' do
          h4 'You own this universe.'
          div {
            a! 'Members list.', 'href_members'
          }
          div {
            a! 'Edit settings.', 'href_edit'
          }
          delete_form 'uni' do
            action 'href_delete'
            submit {
              a_click 'Delete it.'
            }
          end
          
          h4 'You are following:'
          show_if 'follows?' do
            ul {
              loop 'follows' do
                li { a! 'title', 'href'  }
              end
            }
          end
          if_empty 'follows' do
            div.empty_msg 'No one.'
          end
        end
          
        div.teaser '{{club_teaser}}'



      } # div.intro!

      div_guide! 'Stuff you should do:' do
        ul {
          li "Post something in the \"Encyclopedia\" section."
          li "Write anything in the \"Random\" section."
          li %~ Recommend a product in the "Shop" section. ~
          li %~ Ask a question in the "Q & A" section. ~
        }
      end

      div.col.club_messages! do
        
        h4 'Latest Stuff:'

        show_if('no_messages_latest?'){
          div.empty_msg 'No messages yet.'
        }
        
        show_if 'messages_latest?' do
          loop_messages 'messages_latest' 
        end
        
      end
      
    } # div.navigate!

  end # div.inner_shell!
end # div.outer_shell!
