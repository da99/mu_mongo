# VIEW ~/megauni/views/Clubs_read_fights.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_fights.sass
# NAME Clubs_read_fights

div.col.intro! {
  h3 '{{title}}' 

  show_if 'logged_in?' do
    
    form_message_create(
      :title => 'Publish a new',
      :models => %w{fight complaint debate},
      :input_title => true,
      :hidden_input => {
                        :club_filename => '{{club_filename}}',
                        :privacy       => 'public'
                       }
    )
    
  end # logged_in?

} # div.intro!

div.col.navigate! {
  
  club_nav_bar(__FILE__)

  div.club_messages! do
    
    show_if('no_passions?'){
      div.empty_msg 'Nothing passionate or furious has been published.'
    }
    
    loop_messages 'passions'
    
  end
  
} # div.navigate!

