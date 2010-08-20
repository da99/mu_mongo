# MAB     ~/megauni/templates/en-us/mab/Clubs_read_thanks.rb
# VIEW    ~/megauni/views/Clubs_read_thanks.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_read_thanks.sass
# NAME    Clubs_read_thanks
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module MAB_Clubs_read_thanks
  
  def list_name
    'thanks'
  end

  def publisher_guide! 
    div_guide!( 'Stuff you can do here:' ) {
      p %~
            Show how this club or it's members 
          have made your life better.
          ~
    }
  end

  def post_message!
    post_message {
      css_class  'col'
      title  'Post a thank you:'
      hidden_input(
        :message_model => 'thank',
        :club_filename => '{{club_filename}}',
        :privacy       => 'public'
      )
    }
  end

end # === module MAB_Clubs_read_thanks
      
