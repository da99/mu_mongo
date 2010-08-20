# VIEW ~/megauni/views/Clubs_read_fights.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_fights.sass
# NAME Clubs_read_fights

partial '__club_title'

club_nav_bar(__FILE__)

div_centered do
    
    messages! do
      
      loop_messages 'passions'

      if_empty 'passions' do
        show_if 'owner?' do
          div_guide!('Stuff you can do:') {
            p %~
              Express negative feelings. Try to use
            polite profanity, like meathead instead of 
            doo-doo head.
            ~
          }
        end
      end
      
    end
    
    publish! {
      about!
      post_message!
    } # === publish!

end # div_centered
