# VIEW views/News_Control_edit.rb
# SASS /home/da01/MyLife/apps/megauni/templates/English/sass/News_Control_edit.sass
# NAME News_Control_edit

div.content! { 
  
  partial '__flash_msg' 

  a("View", :href=>"{{news_href}}")
  
  h3 '{{title}}'

  form.form_news_edit!(:action=>'{{news_href_update}}', :method=>'post') {

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

    fieldset {
      label 'Tags'
      div.checkboxes {
        mustache 'news_tags' do
          mustache 'tag_included' do
            div.box.selected {
              checkbox true, :name=>"tags[]", :value=>'{{tag}}'
              span '{{tag}}'
            }
          end

          mustache 'tag_not_included' do
            div.box {
              checkbox false, :name=>"tags[]", :value=>'{{tag}}'
              span '{{tag}}'
            }
          end
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

