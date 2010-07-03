# VIEW ~/megauni/views/Clubs_by_filename.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_by_filename.sass
# NAME Club_by_filename


div.col.intro! {
  
  h3 '{{club_title}}' 

  div.teaser '{{club_teaser}}'

  show_if 'logged_in?' do
    
    show_if('club_updator?') {
      div {
        a('Edit settings.', :href=>'{{club_href_edit}}')
      }
    }

    # form_message_create(
    #   :models => %w{random mag_story complaint},
    #   :hidden_input => { :club_filename => '{{club_filename}}',
    #                      :privacy       => 'public'
    #                    }
    # )
    
  end # logged_in?

} # div.intro!


div.col.navigate! {
  
  club_nav_bar(__FILE__)

  div.guide! {
    h4 'Stuff you can do in this club:'
    ul {
      li "Start a fight."
      li "Make a prediction."
      li "Help write the club's encyclopedia."
      li "Ask a question."
    }
  }

  div.club_messages! do
    
    show_if('no_messages_latest?'){
      div.empty_msg 'No messages yet.'
    }
    
    show_if 'messages_latest?' do
      h4 'Latest messages:'
      loop_messages 'messages_latest', :include_meta=>true
    end
    
  end
  
} # div.navigate!

