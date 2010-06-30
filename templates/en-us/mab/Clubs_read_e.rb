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
    
    div.guide! {
      h4 'Stuff you can do:'
      ul {
        li 'Write a story. '
        li 'Start a new chapter.'
        li 'Tell others. '
      }
    }

    form_message_create(
      :title => 'Publish a new:',
      :models => %w{fact story chapter},
      :input_title => true,
      :hidden_input => {
                        :club_filename => '{{club_filename}}',
                        :privacy       => 'public'
                       }
    )
    
  end # logged_in?

  div.club_messages! do
    
    show_if('no_facts?'){
      div.empty_msg 'Nothing has been posted yet.'
    }
    
    loop_messages 'facts'
    
  end
  
} # div.navigate!

