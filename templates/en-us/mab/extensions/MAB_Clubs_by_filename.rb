# MAB     ~/megauni/templates/en-us/mab/Clubs_by_filename.rb
# VIEW    ~/megauni/views/Clubs_by_filename.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_by_filename.sass
# NAME    Clubs_by_filename
# CONTROL models/Club.rb
# MODEL   controls/Club.rb
# 
module MAB_Clubs_by_filename
  
  def list_name
    'messages_latest' 
  end

  def publisher_guide!
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
  end

  def messages! &blok
    div.col.messsages! &blok
  end

  def guide! txt, &blok
    div.section.guide! {
      h3 txt
      blok.call
    }
  end

  def follow!
    show_if('logged_in?') {

      div.sections.follow! {
        show_if 'follower_but_not_owner?' do
          h3.following_it! 'You are following this universe.'
        end
  
        show_if 'potential_follower?' do
          show_if 'single_username?' do
            div.follow_it! {
              a.button("Follow this universe.", :href=>"follow_href".m! )
            }
          end
          mustache 'multiple_usernames?' do
            form.form_follow_create!(:action=>"/uni/follow/", :method=>'post') do
              fieldset {
                label 'Follow this club as: ' 
                select(:name=>'username') {
                  mustache('current_member_usernames') {
                  option('{{username}}', :value=>'{{username}}')
                }
                }
              }
              div.buttons { button 'Follow.' }
            end
          end
        end
        
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
          
        show_if 'follower_but_not_owner?' do
          delete_form 'follow' do
            action 'href_delete_follow'.m!
            submit {
              a_click 'Unfollow'
            }
          end
        end
      } # === follow!
    }
  end # === div_follow

  def about! txt
    div.section.about! {
      show_if 'owner?' do
        h3 "This #{'club_type'.m!} is yours:"
      end
      if_not 'owner?' do
        h3 "About this #{'club_type'.m!}:"
      end
      div.teaser 'club_teaser'.m!
    }
  end
  
  def edit!
    show_if 'owner?' do
        div.edit_settings! {
          a_button 'Edit settings.', 'href_edit'   
          p %~
            Edit title, teaser, or choose to delete this {{club_type}}
          ~
        }
    end
  end
  
  def memberships!
    show_if 'owner?' do
        show_if 'memberships?' do
          div.section.memberships! {
            h4 'Memberships:'
            ul {
              loop 'memberships' do
                li { a! "Withdraw as: name.m", 'href' }
              end
            }
          }
        end
        
        div.section.add_memberships! {
          h4 'Add Members:'
          p %~Members are given special powers.
          Separate each with a new line.~
          post_form('add_member') {
            textarea ''
          }
        } # === add_memberships!
    end
  end # === div_memberships

  def publish! &blok
    div.col.publish! &blok
  end
   
  
end # === module
