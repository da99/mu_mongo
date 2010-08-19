# VIEW ~/megauni/views/Clubs_read_qa.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_qa.sass
# NAME Clubs_read_qa

h3.main '{{title}}' 
div.keyword { 
  span.title 'keyword:'
  span.keyword 'factor'
}
club_nav_bar(__FILE__)

div_centered do
    
    div.club_body! {

      show_if 'logged_in?' do
        
        div_guide!('Stuff you can do here:') {
          p %~
            Help others by answering questions.
          ~
        } # === div_guide!

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
        
      end # logged_in?
      
      div.col.club_messages! do
        
        loop_messages_with_opening(
          'questions',
          'Latest Questions:',
          'No questions have been asked.'
        )
        
      end

    } # div.club_body!
    
end # div.outer_shell!
    
