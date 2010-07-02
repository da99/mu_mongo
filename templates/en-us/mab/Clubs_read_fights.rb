# VIEW ~/megauni/views/Clubs_read_fights.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_fights.sass
# NAME Clubs_read_fights

# div.col.intro! {
# } # div.intro!

div.col.navigate! {
  
  h3 '{{title}}' 
  
  club_nav_bar(__FILE__)

  show_if 'logged_in?' do
    
    div.guide! {
      h4 'Stuff you can do:'
      p %~
        Express negative feelings. Try to use
      polite profanity, like meathead instead of 
      doo-doo head.
      ~
    }
    form_message_create(
      :title => 'Publish a new:',
      :models => %w{fight complaint debate},
      :input_title => true,
      :hidden_input => {
                        :club_filename => '{{club_filename}}',
                        :privacy       => 'public'
                       }
    )
    
  end # logged_in?

  div.club_messages! do
    
    show_if('no_passions?'){
      div.empty_msg 'Nothing passionate or furious has been published.'
    }
    
    loop_messages 'passions'
    
  end
  
} # div.navigate!
