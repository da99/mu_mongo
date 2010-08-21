# MAB     ~/megauni/templates/en-us/mab/Clubs_read_qa.rb
# VIEW    ~/megauni/views/Clubs_read_qa.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_read_qa.sass
# NAME    Clubs_read_qa
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module MAB_Clubs_read_qa
  
  include BASE_MAB
  
  def list_name
    'questions'
  end

  def publisher_guide!
    super { 
      insider {
        guide!('Stuff you can do here:') {
          p %~
            Ask questions.
          ~
        } # === div_guide!
      }
      
      owner {
        guide!('Stuff you can do here:') {
          p %~
            Ask questions and answer them
          ~
        } # === div_guide!
      }
    }
  end

  def post_message!
    post_message {
      css_class  'col'
      title  'Publish a new:'
      models  %w{question plea}
      input_title
      hidden_input(
        :club_filename => '{{club_filename}}',
        :privacy       => 'public'
      )
    }
  end

end # === module MAB_Clubs_read_qa
      
