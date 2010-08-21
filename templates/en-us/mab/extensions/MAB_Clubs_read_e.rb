# MAB     ~/megauni/templates/en-us/mab/Clubs_read_e.rb
# VIEW    ~/megauni/views/Clubs_read_e.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME    Clubs_read_e
# CONTROL models/Club.rb
# MODEL   controls/Club.rb
# 
module MAB_Clubs_read_e
  
  include BASE_MAB

  def list_name
    'quotes_or_chapters'
  end

  def publisher_guide!
    show_to_owner_if_empty('quotes_or_chapters?') do
      guide!('Stuff you can do:') {
        ul {
          li 'Write a story. '
          li 'Post a quotation.'
          li 'Tell others of related links.'
        }
      }
    end
  end

  def follow!
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

end # === module
