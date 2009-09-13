save_to('title') { 'Create News' }

partial('__nav_bar')


div.content!  { 
  
  h3 'Create News'

  form.single.form_new_news!(:action=>'/news/', :method=>'post') {
  
    fieldset {
      label 'Title'
      input.text( :id=>"news_title", :name=>"title", :type=>"text" )
    }

    fieldset {
      label 'Teaser'
      textarea('', :id=>"news_teaser", :name=>"teaser")
    }

    fieldset {
      label 'body'
      textarea('', :id=>"news_body", :name=>"body")      
    }

    fieldset {
      label 'Tags'
    }

    div.buttons {
      button.create 'Create News', :onclick=>"document.getElementById('form_news_new').submit(); return false;" 
    }


  } # === form
} # === div.content!
