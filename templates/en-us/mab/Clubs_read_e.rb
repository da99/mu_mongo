# VIEW ~/megauni/views/Clubs_read_e.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME Clubs_read_e

h3.club_title! '{{title}}' 

club_nav_bar(__FILE__)

div.outer_shell! do
  div.inner_shell! do
    
    div.club_body! {

      show_if 'logged_in?' do
        
        div.col.mind_control! {
          
          div_guide! 'Stuff you can do:' do
            ul {
              li 'Write a story. '
              li 'Post a quotation.'
              li 'Tell others of related links.'
            }
          end

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
          
        } # === mind_control!
        
      end # logged_in?

      div.col.club_messages! do
        
        show_if('no_quotes_or_chapters?'){
          div.empty_msg 'Nothing has been posted yet.'
        }
        
        loop_messages_with_opening 'quotes', 'Quotations'
        
        loop_messages_with_opening 'chapters', 'Chapters'
      end
      
    } # div.navigate!

  end # div.inner_shell!
end # div.outer_shell!
