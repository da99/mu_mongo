# VIEW views/Members_life.rb
# SASS ~/megauni/templates/en-us/sass/Members_life.sass
# NAME Members_life

div.col.navigate! {
  
  h3 '{{title}}'
  
  life_club_nav_bar('_id')

  div.club_messages! do
    
    show_if('no_stream?'){
      div.empty_msg 'No messages have been posted.'
    }
    
    loop_messages 'stream'
    
  end
  
} # div.navigate!

div.col.intro! {


  show_if('owner?') {
    
    form_message_create(
      :hidden_input => {:target=>'{{username_id}}'}
    )

  } # show_if
  

} # div.intro!


# partial('__nav_bar')

