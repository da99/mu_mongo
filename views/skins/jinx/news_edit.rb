save_to('title') { 'Editing: ' + the_app.doc.data.title }

partial('__nav_bar')

div.content!  {

  partial '__flash_msg' if the_app.flash_msg?

  a("View", :href=>"/news/#{the_app.doc._id}/")
  
  h3 @title # "Editing: #{app_vars[:news][:title]}" 

  form.form_news_edit!(:action=>"/news/#{the_app.doc._id}/", :method=>'post') {

    fieldset {
      label 'Title'
      input.text( :value=>the_app.doc.data.title, :id=>"news_title", :name=>"title", :type=>"text" )
    }

    fieldset {
      label 'Teaser'
      textarea(the_app.doc.teaser, :id=>"news_teaser", :name=>"teaser")
    }

    fieldset {
      label 'body'
      textarea(the_app.doc.body, :id=>"news_body", :name=>"body")
    }

    fieldset {
      label 'Tags'
      div.checkboxes {
        the_app.news_tags.each { |t|
          if the_app.doc.tags.include?(t)
            div.box.selected {
              checkbox true, :name=>"tags[]", :value=>t
              span t
            }
          else
            div.box {
              checkbox false, :name=>"tags[]", :value=>t
              span t
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

