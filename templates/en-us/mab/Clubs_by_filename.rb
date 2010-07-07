# VIEW ~/megauni/views/Clubs_by_filename.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_by_filename.sass
# NAME Club_by_filename



div.col.navigate! {
  
  h3 '{{club_title}}' 
  
  club_nav_bar(__FILE__)

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

  div.col.guide! {
    h4 'Stuff you should do:'
    ul {
      li "Post something in the \"Encyclopedia\" section."
      li "Write anything in the \"Random\" section."
      li %~ Recommend a product in the "Shop" section. ~
      li %~ Ask a question in the "Q & A" section. ~
    }
  }

  div.col.club_messages! do
    
    h4 'Latest Messages Posted:'

    show_if('no_messages_latest?'){
      div.empty_msg 'No messages yet.'
    }
    
    show_if 'messages_latest?' do
      loop_messages 'messages_latest', :include_meta=>true
    end
    
  end
  
} # div.navigate!

