# VIEW ~/megauni/views/Clubs_read_e.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME Clubs_read_e

h3.club_title! '{{title}}' 

club_nav_bar(__FILE__)

div.outer_shell! do
  div.inner_shell! do
    
    div.club_body! {

      show_if 'logged_in?' do
        
        div_guide! 'Stuff you can do:' do
          ul {
            li 'Write a story. '
            li 'Post a quotation.'
            li 'Tell others of related links.'
          }
        end

        form_message_create(
          :css_class => 'col',
          :title => 'Publish a new:',
          :input_title => true,
          :models => %w{e_quote e_chapter},
          :hidden_input => {
                            :club_filename => '{{club_filename}}',
                            :privacy       => 'public'
                           }
        )
        
      end # logged_in?

      div.col.club_messages! do
        
        show_if('no_facts?'){
          div.empty_msg 'Nothing has been posted yet.'
        }
        
        loop_messages 'facts'
        
      end
      
    } # div.navigate!

  end # div.inner_shell!
end # div.outer_shell!
