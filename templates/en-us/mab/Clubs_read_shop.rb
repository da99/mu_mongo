# VIEW views/Clubs_read_shop.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_shop.sass
# NAME Clubs_read_shop

div.col.intro! {
  h3 '{{title}}' 

} # div.intro!

div.col.navigate! {
  
  club_nav_bar(__FILE__)

  div.club_messages! do
    
    show_if('no_buys?'){
      div.empty_msg 'Nothing has been posted yet.'
    }
    
    loop_messages 'buys'
    
  end
  
} # div.navigate!

