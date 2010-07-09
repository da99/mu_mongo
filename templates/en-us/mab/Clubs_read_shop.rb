# VIEW views/Clubs_read_shop.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_shop.sass
# NAME Clubs_read_shop

h3.club_title! '{{title}}' 

club_nav_bar(__FILE__)

div.outer_shell! do
  div.inner_shell! do
    
    div.club_body! {

      show_if 'logged_in?' do
        
        div_guide!( 'Stuff you can do here:' ) {
          p %~
            You post your favorite stuff to buy.
          Tell people: 
          ~
          ul {
            li 'where you bought it.'
            li 'how much it cost you.'
            li 'why others should buy it too.'
          }
        }

          form_message_create(
          :css_class => 'col',
            :title => 'Recommend a product:',
            :hidden_input => {
                              :message_model => 'buy',
                              :club_filename => '{{club_filename}}',
                              :privacy       => 'public'
                             }
          )
        
      end # logged_in?


      div.col.club_messages! do
        
        show_if('no_buys?'){
          div.empty_msg 'Nothing has been posted yet.'
        }
        
        loop_messages 'buys'
        
      end
      
    } # div.navigate!

  end # div.inner_shell!
end # div.outer_shell!
