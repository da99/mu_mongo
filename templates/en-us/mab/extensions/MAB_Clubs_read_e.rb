# MAB     ~/megauni/templates/en-us/mab/Clubs_read_e.rb
# VIEW    ~/megauni/views/Clubs_read_e.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME    Clubs_read_e
# CONTROL models/Club.rb
# MODEL   controls/Club.rb
# 

module MAB_Clubs_read_e_STRANGER
end


module MAB_Clubs_read_e_MEMBER
end

module MAB_Clubs_read_e_INSIDER
  def publisher_guide
    p 'publisher guide goes here'
  end
end

module MAB_Clubs_read_e_OWNER
  def publisher_guide
    p 'publisher guide goes here'
  end
end

module MAB_Clubs_read_e
  
  def messages_list
    [ 
      { 'quotes' => 'Quotations'},
      { 'chapters' => 'Chapters' }
    ]
  end

  def insider_publisher_guider
    guide('Stuff you can do:') {
      ul {
        li 'Write a story about this person.'
        li 'Post a quotation about this person.'
      }
    }
  end

  def owner_publisher_guide
    guide('Stuff you can do:') {
      ul {
        li 'Write a story. '
        li 'Post a quotation.'
      }
    }
  end

  def post_message!
    post_message {
      css_class  'col'
      title  'Publish a new:'
      input_title 
      models  %w{e_quote e_chapter}
      hidden_input(
        :club_filename => '{{club_filename}}',
        :privacy       => 'public'
      )
    }
  end
  
  def about
    super('* * *', '----')
  end

  def publisher_guide
  end

end # === module
