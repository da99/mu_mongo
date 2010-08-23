
module BASE_MAB_Clubs

  def list_name
    self.class.to_s.split('Clubs_').last
  end

  def messages! &blok
    div.col.messages! &blok
  end

  def loop_messages_or_guide
    loop_messages
    if_empty list_name do
      publisher_guide!
    end
  end

  def guide txt, &blok
    h3 txt
    blok.call
  end
  
  def publisher_guide! 
    raise "Block not accepted" if block_given?

    div.section.guide.publisher_guide! do
      
      owner {
        publisher_guide
      }
      
      insider {
        publisher_guide
      }
      
    end
  end
  
  def omni_follow
    show_if('logged_in?') {

      div.sections.follow! {
        show_if 'follower_but_not_owner?' do
          h3.following_it! 'You are following this universe.'
        end
  
        show_if 'potential_follower?' do
          show_if 'single_username?' do
            div.follow_it! {
              a_button("Follow this universe.", "href_follow".m! )
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
  end
  alias_method :follow!, :omni_follow

  def about header, body
    div.section.about {
      h3 header.m!
      div.body body.m!
    }
  end
  
  def about! &blok
    div.col.about! &blok
  end
 
  def publish! &blok
    div.col.publish! &blok
  end 
  
  def owner_not_life? &blok
    show_if 'not_life?', &blok
  end

end # === module
