# VIEW ~/megauni/views/Clubs_read_qa.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_qa.sass
# NAME Clubs_read_qa

# div.col.intro! {
# 
# } # div.intro!

div.col.navigate! {

  h3 '{{title}}' 

  club_nav_bar(__FILE__)

  show_if 'logged_in?' do
    
    div.guide! {
      h4 'Stuff you can do here:'
      p %~
        Help others by answering questions.
      ~
    }

    form_message_create(
			:title => 'Publish a new:',
      :models => %w{question plea},
      :hidden_input => {
        :club_filename => '{{club_filename}}',
        :privacy       => 'public'
      }
    )
    
  end # logged_in?
  
  div.club_messages! do
    
    show_if('no_questions?'){
      div.empty_msg 'No questions have been asked.'
    }
    
    loop_messages 'questions'
    
  end

} # div.navigate!
