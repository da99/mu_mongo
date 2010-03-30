# VIEW views/Clubs_by_id.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/English/sass/Clubs_by_id.sass
# NAME Clubs_by_id

div.content! { 
  
  partial '__flash_msg'

  h3 '{{club_title}}'
  
  mustache 'logged_in?' do
    div.club_message_create! do
      h4 'Post a message:'  
      form :id=>"form_club_message_create", :method=>'POST', :action=>"/messages/" do
        input :type=>'hidden', :name=>'target_ids', :value=>'{{club_filename}}'
        fieldset {
          textarea '', :name=>'body'
        }
        div.buttons {
          button.create 'Save'
        }
      end
    end
  end

  div.club_messages! do
    mustache 'no_messages_latest' do
      div.empty_msg 'No messages yet.'
    end
    mustache 'messages_latest' do
      div.message {
        div.body( '{{{compiled_body}}}' )
        div.permalink {
          a('Permalink', :href=>"{{href}}")
        }
      }
    end
  end
  
} # === div.content!


partial('__nav_bar')

