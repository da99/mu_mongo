save_to('title') { app_vars[:heart][:title] }


partial('__nav_bar')


div.content! { 
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
  

  div.heart_link {
   
   div.info {
    span.published_at app_vars[:heart][:published_at].strftime('%b  %d, %Y')
   }
   h4 app_vars[:heart][:title]
   div.body { app_vars[:heart][:body] }
  }
  
} # === div.content!


