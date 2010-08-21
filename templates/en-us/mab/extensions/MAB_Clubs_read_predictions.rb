# MAB     ~/megauni/templates/en-us/mab/Clubs_read_predictions.rb
# VIEW    ~/megauni/views/Clubs_read_predictions.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_read_predictions.sass
# NAME    Clubs_read_predictions
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module MAB_Clubs_read_predictions
  
  include BASE_MAB
  
  def publisher_guide!
      show_owner_if_empty 'predictions' do
        guide( 'Stuff you can do here:' ) {
          p %~
            This is where you can publish your thoughts
          on what will happen in the future.  When
          you are right, you can yell, "I told you so!"
          ~
        }
      end
  end

  def post_message!

          post_message {
            css_class  'col'
            title  'Post a prediction:'
            hidden_input(
              :message_model => 'prediction', 
              :club_filename => '{{club_filename}}',
              :privacy       => 'public'
            )
          }
        
  end

end # === module MAB_Clubs_read_predictions
      
