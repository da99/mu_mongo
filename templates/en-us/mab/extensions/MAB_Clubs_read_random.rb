# MAB     ~/megauni/templates/en-us/mab/Clubs_read_random.rb
# VIEW    ~/megauni/views/Clubs_read_random.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_read_random.sass
# NAME    Clubs_read_random
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module MAB_Clubs_read_random_STRANGER
end

module MAB_Clubs_read_random_MEMBER
end

module MAB_Clubs_read_random_INSIDER
  
  def post_message
        super {
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

  def publisher_guide
      guide( 'Stuff you can do here:' ) {
        p %~
          Post random thoughts about this {{club_type}}:
        ~
      }
  end

end

module MAB_Clubs_read_random_OWNER
  
  include MAB_Clubs_read_random_INSIDER

  def publisher_guide
      guide( 'Stuff you can do here:' ) {
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

module MAB_Clubs_read_random
  
  def messages_list
    'randoms'
  end

  def about 
    super('* * *', '- - -')
  end

  def publisher_guide
    p 'Nothing posted yet.'
  end

end # === module MAB_Clubs_read_random
      
