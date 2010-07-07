# VIEW ~/megauni/views/Clubs_read_e.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME Clubs_read_e

# div.col.intro! {
# 
# } # div.intro!

div.col.navigate! {
  
  h3 '{{title}}' 
  
  club_nav_bar(__FILE__)

  show_if 'logged_in?' do
    
    div.col.guide! {
      h4 'Stuff you can do:'
      ul {
        li 'Write a story. '
        li 'Post a quotation.'
        li 'Tell others of related links.'
      }
    }

    div.col.message_create! {
      form_message_create(
        :title => 'Publish a new:',
        :input_title => true,
        :models => %w{e_quote e_chapter},
        :hidden_input => {
                          :club_filename => '{{club_filename}}',
                          :privacy       => 'public'
                         }
      )
    }
    
  end # logged_in?

  div.col.club_messages! do
    
    show_if('no_facts?'){
      div.empty_msg 'Nothing has been posted yet.'
    }
    
    loop_messages 'facts'
    
  end
  
} # div.navigate!

