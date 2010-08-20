# MAB     ~/megauni/templates/en-us/mab/Clubs_read_random.rb
# VIEW    ~/megauni/views/Clubs_read_random.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_read_random.sass
# NAME    Clubs_read_random
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module MAB_Clubs_read_random
  
  def publisher_guide!
    show_to_owner_if_empty list_name do
      guide!( 'Stuff you can do here:' ) {
        p %~
          Post stuff that no one really 
        cares about. Examples:
        ~
        ul {
          li 'Thoughts on economics.'
          li 'Opinions on religion.'
          li 'Wonder why the world is against you.'
        }
      }
    end
  end

  def post_message!
        post_message {
          css_class  'col'
          title  'Post a random thought:'
          input_title 
          hidden_input(
            :message_model => 'random',
            :club_filename => '{{club_filename}}',
            :privacy       => 'public'
          )
        }
  end

end # === module MAB_Clubs_read_random
      
