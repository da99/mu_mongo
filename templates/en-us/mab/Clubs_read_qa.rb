# VIEW ~/megauni/views/Clubs_read_qa.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_qa.sass
# NAME Clubs_read_qa

h3.club_title! '{{title}}' 

club_nav_bar(__FILE__)

div.outer_shell! do
  div.inner_shell! do
    
    div.club_body! {

      show_if 'logged_in?' do
        
        div_guide!('Stuff you can do here:') {
          p %~
            Help others by answering questions.
          ~
        } # === div_guide!

          form_message_create(
          :css_class => 'col',
            :title => 'Publish a new:',
            :models => %w{question plea},
            :hidden_input => {
              :club_filename => '{{club_filename}}',
              :privacy       => 'public'
            }
          )
        
      end # logged_in?
      
      div.col.club_messages! do
        
        show_if('no_questions?'){
          div.empty_msg 'No questions have been asked.'
        }
        
        loop_messages 'questions'
        
      end

    } # div.club_body!
    
  end # div.inner_shell!
end # div.outer_shell!
    
