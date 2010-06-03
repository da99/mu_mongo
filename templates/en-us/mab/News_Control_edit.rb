# VIEW views/News_Control_edit.rb
# SASS /home/da01/MyLife/apps/megauni/templates/en-us/sass/News_Control_edit.sass
# NAME News_Control_edit

div.content! { 
  

  a("View", :href=>"{{news_href}}")
  
  h3 '{{title}}'

  form.form_news_edit!(:action=>'{{news_href_update}}', :method=>'post') {

    _input_put_method
    
    fieldset {
      label 'Title'
      input.text( :value=>'{{news_title}}', :id=>"news_title", :name=>"title", :type=>"text" )
    }

    fieldset {
      label 'Teaser'
      textarea('{{news_teaser}}', :id=>"news_teaser", :name=>"teaser")
    }

    fieldset {
      label 'body'
      textarea('{{news_body}}', :id=>"news_body", :name=>"body")
    }

    p 'Published: {{news_published_at}}'
    p 'Created: {{news_created_at}}'
    # p 'Updated: {{news_updated_at}}'

    fieldset {
      label 'Club'
      menu_for 'clubs', :name=>'club_id' do
        option 'title', :value=>'id'
      end
    }

    fieldset {
      label 'Tags'
      div.checkboxes {
        checkboxes_for 'news_tags', :name=>'tags[]' do
          checkbox 'filename',  :value=>'filename'
        end
      } # === checkboxes
    } # === fieldset

    div.buttons {
      input :value=>'put', :name=>'_method', :type=>'hidden'
      button.update 'Update', :onclick=>"document.getElementById('form_news_edit').submit(); return false;"
    }

  } # === form

  
} # === div.content!

partial('__nav_bar')

