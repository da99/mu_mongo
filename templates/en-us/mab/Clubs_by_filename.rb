# VIEW ~/megauni/views/Clubs_by_filename.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_by_filename.sass
# NAME Club_by_filename


h3.club_title! '{{club_title}}' 

club_nav_bar(__FILE__)

div.outer_shell! do
  
  div.inner_shell! do
    
    div.club_body! {

      div.col.intro! {

        h4 'About this universe:'
        
        mustache 'owner?' do
          p 'You own this universe.'
        end
          
        div.teaser '{{club_teaser}}'

        show_if 'logged_in?' do

          show_if('club_updator?') {
            div {
              a('Edit settings.', :href=>'{{club_href_edit}}')
            }
          }

        end # logged_in?

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
          loop_messages 'messages_latest', :include_meta=>true
        end
        
      end
      
    } # div.navigate!

  end # div.inner_shell!
end # div.outer_shell!
