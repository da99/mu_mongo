save_to('title') { 'Editing: ' + app_vars[:news][:title] }

partial('__nav_bar')

div.content!  {

  partial '__flash_msg' if the_app.flash_msg?

  a("View", :href=>"/news/#{app_vars[:news][:id]}/")
  
  h3 @title # "Editing: #{app_vars[:news][:title]}" 

  form.form_news_edit!(:action=>"/news/#{app_vars[:news][:id]}/", :method=>'post') {

    fieldset {
      label 'Title'
      input.text( :value=>app_vars[:news][:title], :id=>"news_title", :name=>"title", :type=>"text" )
    }

    fieldset {
      label 'Teaser'
      textarea(app_vars[:news][:teaser], :id=>"news_teaser", :name=>"teaser")
    }

    fieldset {
      label 'body'
      textarea(app_vars[:news][:body], :id=>"news_body", :name=>"body")
    }

    fieldset {
      label 'Tags'
      div.checkboxes {
        app_vars[:news_tags].each { |t|
          if app_vars[:news].has_tag_id?(t[:id])
            div.box.selected {
              checkbox true, :name=>"tags[]", :value=>t[:id]
              span t[:filename]
            }
          else
            div.box {
              checkbox false, :name=>"tags[]", :value=>t[:id]
              span t[:filename]
            }
          end
        } 
      }
    }

    div.buttons {
      input :value=>'put', :name=>'_method', :type=>'hidden'
      button.update 'Update', :onclick=>"document.getElementById('form_news_edit').submit(); return false;"
    }


  } # === form
} # === div.content!

