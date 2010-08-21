# MAB     ~/megauni/templates/en-us/mab/Clubs_by_filename.rb
# VIEW    ~/megauni/views/Clubs_by_filename.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_by_filename.sass
# NAME    Clubs_by_filename
# CONTROL models/Club.rb
# MODEL   controls/Club.rb
# 
module MAB_Clubs_by_filename
  
  include BASE_MAB

  %w{ post_membership_plea memberships_guide }.each { |meth|
    %w{ stranger member insider owner}.each { |level|
      eval %~
        def #{level}_#{meth}!
          div "#{level} :: #{meth} goes here."
        end
      ~
    }
  }

  def list_name
    'messages_latest' 
  end

  def publisher_guide!
      if_empty('messages_latest'){
        show_if 'owner?' do
          guide('Stuff you should do:') {
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

  def follow!
    return super
    show_if('logged_in?') {

      div.sections.follow! {
        show_if 'follower_but_not_owner?' do
          h3.following_it! 'You are following this universe.'
        end
  
        show_if 'potential_follower?' do
          show_if 'single_username?' do
            div.follow_it! {
              a.button("Follow this universe.", :href=>"href_follow".m! )
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

  # =============== ABOUT 

  def stranger_about
    about "About this {{club_type}}:", 'club_teaser'
  end
  
  def member_about
    stranger_about
  end

  def insider_about
    about "You're an insider:", 'club_teaser'
  end

  def owner_about
    about "This {{club_type}} is yours:", 'You own it. You can edit it, destroy it, or publish to it.'
  end
  
  # =============== MEMBERSHIPS
  
  def omni_memberships
    security = (ring == :owner ? 'all' : 'public')
    
    show_if 'memberships?' do
      h3 'Members:'
    end
    
    loop "#{security}_memberships" do
      div {
        div 'title'.m!
        div 'privacy'.m!
      }
    end
  end
  

  def memberships! &blok
      div.col.memberships! &blok
  end
  
  def memberships
    show_if 'owner?' do
        show_if 'memberships?' do
          div.section.memberships {
            h4 'Memberships:'
            ul {
              loop 'memberships' do
                li { a! "Withdraw as: name.m", 'href' }
              end
            }
          }
        end
        
        div.section.add_memberships {
          h4 'Add Members:'
          p %~Members are given special powers.
          Separate each with a new line.~
          form_post('add_member' + rand(1000).to_s) {
            textarea ''
          }
        } # === add_memberships!
    end
  end # === div_memberships
  # =============== FOR OWNER
   
  def owner_edit!
    div.edit_settings! {
      a_button 'Edit settings.', 'href_edit'   
      p %~
        Edit title, teaser, or choose to delete this {{club_type}}
      ~
    }
  end
  
  def owner_memberships_guide!
    div.section { p 'Memberrship guide goes here.' }
  end

  def owner_post_membership!
    div.section { p 'Post form membership goes here.' }
  end

  def publish! &blok
    div.col.publish! &blok
  end
  
  
end # === module
