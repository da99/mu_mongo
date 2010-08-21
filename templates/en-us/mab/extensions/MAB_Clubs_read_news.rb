# MAB     ~/megauni/templates/en-us/mab/Clubs_read_news.rb
# VIEW    ~/megauni/views/Clubs_read_news.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_read_news.sass
# NAME    Clubs_read_news
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module MAB_Clubs_read_news
  
  include BASE_MAB
  
  def publisher_guider! list_name
      show_to_owner_if_empty('news') do
        guide!( 'Stuff you can do here:' ) {
          p %~
            Post only important news. 
          Examples:
          ~
          ul {
            li 'Your plane landed in Dallas.'
            li 'You got a job demotion.'
            li 'You broke up with your dog walker.'
            li 'You got arrested... again.'
          }
        }
      end
  end

  def post_message!
          post_message {
            css_class  'col'
            title  'Post news:'
            input_title 
            hidden_input(
              :message_model => 'news', 
              :club_filename => '{{club_filename}}',
              :privacy       => 'public'
            )
          }
  end

end # === module MAB_Clubs_read_news
      
