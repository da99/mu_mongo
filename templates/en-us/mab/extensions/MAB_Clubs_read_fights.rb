# MAB     ~/megauni/templates/en-us/mab/Clubs_read_fights.rb
# VIEW    ~/megauni/views/Clubs_read_fights.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_read_fights.sass
# NAME    Clubs_read_fights
# CONTROL models/Club.rb
# MODEL   controls/Club.rb
# 
module MAB_Clubs_read_fights

  def post_message!
    post_message {
      css_class  'col'
      title      'Publish a new:'
      models     %w{fight complaint debate}
      input_title 
      hidden_input(
        :club_filename => '{{club_filename}}',
        :privacy       => 'public'
      )
    }
  end

end # === module
