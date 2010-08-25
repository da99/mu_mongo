# MAB     ~/megauni/templates/en-us/mab/Clubs_read_magazine.rb
# VIEW    ~/megauni/views/Clubs_read_magazine.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_read_magazine.sass
# NAME    Clubs_read_magazine
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module MAB_Clubs_read_magazine
  
  def publisher_guide!
    show_to_owner_if_empty 'storys' do
      guide( 'Stuff you can do:' ) {
        ul {
          li 'Write a story.'
          li 'Review a restaurant.'
          li 'Write about a family reunion.'
        }
      }
    end
  end

  def post_message!
      post_message {
        css_class'col'
        title  'Publish a new story:'
        input_title 
        hidden_input(
          :message_model => 'mag_story',
          :club_filename => '{{club_filename}}',
          :privacy       => 'public'
        )
      }
  end

end # === module MAB_Clubs_read_magazine
      
