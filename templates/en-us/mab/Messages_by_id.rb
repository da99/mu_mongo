# VIEW views/Messages_by_id.rb
# SASS ~/megauni/templates/en-us/sass/Messages_by_id.sass
# NAME Messages_by_id

show_if 'show_moving_message?' do
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
end

h3.club_title! '{{club_title}}' 

club_nav_bar __FILE__

h3.message_title '{{message_title}}'

div_centered { 
  
    div.message!{

      mustache 'message_data' do
        div.body { '{{{compiled_body}}}' }
      end

      show_if 'logged_in?' do
        
        div.notify_me! {
        
          if_not 'notify_me?' do
              
            post_to_username('notify') {
              as_radios
              action '{{message_href_notify}}'
              button_create 'Notify me.'
              show {
                a_click 'Notify me '
                span ' of activity for this {{message_model_in_english}}.'
              } # === show 
            }
            
          end
        
          show_if 'notify_me?' do  
            delete_form('notify') {
              action "{{message_href_notify}}"
              a_submit 'Stop'
              span ' notifying me.'
            }
          end
          
        } # === div.notify_me!
        
        show_if 'not_reposted?' do
          div.repost! {
            
            post_to_universes('repost_form') {
              action "{{message_href_repost}}"
              button_create 'Re-post.'
              show {
                a_click 'Re-post.'
              }
            }
              
          } # === div
        end

      end # === show_if 'logged_in?'
      

      div.about! {

        h4 'About this content:'
        
        div {
          strong "Published on:"
          br
          span '{{published_at}}'
        }
        
        div {
          strong "Type:"
          br
          span "{{message_model_in_english}}."
        }
        
        div {
          strong 'Publication:'
          br
          a('{{club_title}}', :href=>'{{club_href}}')
        }
        
        div {
          strong 'Section: '
          br
          a('{{message_section}}', :href=>'{{message_section_href}}')
        }
        
        show_if 'message_has_parent?' do
          div {
            strong 'A reply to:'
            br
            a('this message', :href=>'{{message_parent_href}}')
          }
        end

        show_if 'message_updator?' do
          div {
            strong 'Actions:'
            br
            a('Edit.', :href=>'{{message_href_edit}}')
            show_if 'message_updated?' do
              br 
              a('View changes.', :href=>'{{message_href_log}}')
            end
          }
        end

      } # div.about!

      div.replies! {

        div.responds! {
          [ 
            ['suggests', '{{suggestions_or_answers}}'],
            ['critiques', 'Praise & Criticism:'],
            ['questions', 'Questions:']
          ].each { |mod, txt|
            show_if "#{mod}?" do
              div(:id=>mod) {
                h4 txt
                loop_messages(mod) { 
                  permalink
                }
              } 
            end
          }

        } # === div.responds!

        show_if 'logged_in?' do
          
          div.reply! {
            
            div.guide! {
              h4 'Stuff you can do:'
              p %~
                Express negative feelings. Try to use
              polite profanity, like meathead instead of 
              doo-doo head.
              ~
            }
            
            post_message {
              title 'Publish a new:'
              models %w{cheer jeer question suggest}
              hidden_input(
                :parent_message_id => '{{message_id}}',
                :privacy           => 'public'
              )
            }
            
          } # === div.reply!
          
        end # logged_in?
        
      } # === div.reply!
  
  
    } # === div.message!
} # === div_centered

