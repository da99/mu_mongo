# VIEW ~/megauni/views/Clubs_read_qa.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_qa.sass
# NAME Clubs_read_qa

h3 'Q&A: {{club_title}}' 

div.teaser '{{club_teaser}}'

club_nav_bar(__FILE__)

show_if 'logged_in?' do
  
  form_message_create(
    :title => 'Ask a question:',
    :hidden_input => Hash.new[
                      :message_model => 'question',
                      :club_filename => '{{club_filename}}',
                      :privacy       => 'public'
                     ]
  )
  
end # logged_in?


div.club_messages! do
  
  show_if('no_questions'){
    div.empty_msg 'No questions have been asked.'
  }
  
  loop_messages 'questions'
  
end
