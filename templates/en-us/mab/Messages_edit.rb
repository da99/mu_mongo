# VIEW views/Messages_edit.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Messages_edit.sass
# NAME Messages_edit

div.content! { 
  
  
  form(:id=>'form_messages_update', :action=>"{{mess_href}}", :method=>'post' ) do
    input :type=>'hidden', :name=>'_method', :value=>'put'

    mustache 'mess_data' do
      fieldset {
        label 'Title:'
        input.text :type=>'text', :name=>'title', :value=>'{{title}}'
      }

      fieldset {
        label 'Body:'
        textarea '{{body}}', :name=>'body'
      }
    end

    div.buttons {
      button 'Save'
    }

  end

  a('Cancel and go back to message.', :href=>"{{mess_href}}")
  
} # === div.content!

partial('__nav_bar')

