save_to('title') { 'Editing: ' + app_vars[:news][:title] }

partial('__nav_bar')

div.content!  {

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
    }

    div.buttons {
      input :value=>'put', :name=>'_method', :type=>'hidden'
      button.update 'Update', :onclick=>"document.getElementById('form_news_edit').submit(); return false;"
    }


  } # === form
} # === div.content!

