save_to('title') { app_vars[:news][:title] }


partial('__nav_bar')


div.content! { 
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
  

  div.heart_link {
   
   div.info {
    span.published_at app_vars[:news][:published_at].strftime('%b  %d, %Y')
   }
   h4 app_vars[:news][:title]
   div.body { app_vars[:news][:body] }

   div.tags {
    app_vars[:news].taggings.each do |tagging|
      p tagging.tag.filename
    end
   }
  }
  
} # === div.content!



