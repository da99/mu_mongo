# MAB     ~/megauni/templates/en-us/mab/Clubs_read_shop.rb
# VIEW    ~/megauni/views/Clubs_read_shop.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_read_shop.sass
# NAME    Clubs_read_shop
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module MAB_Clubs_read_shop
  
  include BASE_MAB
  
  def list_name
    'buys'
  end

  def loop_messages!
    loop_messages list_name
  end

  def publisher_guide!
      guide( 'Stuff you can do here:' ) {
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
  end
  
  def post_message!
    post_message {
      css_class  'col'
      title  'Recommend a product:'
      input_title 
      hidden_input(
        :message_model => 'buy',
        :club_filename => '{{club_filename}}',
        :privacy       => 'public'
      )
    }
  end

end # === module MAB_Clubs_read_shop
      
