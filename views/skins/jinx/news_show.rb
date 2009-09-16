save_to('title') { the_app.model_instance[:title] }


partial('__nav_bar')


div.content! { 
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
  

  div.heart_link {
   
   div.info {
    span.published_at the_app.model_instance[:published_at].strftime('%b  %d, %Y')
   }
   h4 the_app.model_instance[:title]
   div.body { the_app.model_instance[:body] }

   div.tags {
    if the_app.model_instance.updator?(the_app.current_member)
      a('Edit', :href=>"#{the_app.request.path_info}edit/")
    end
    the_app.model_instance.taggings_dataset.eager(:tag).all.each do |tagging|
      p tagging.tag.filename
    end
   }
  }
  
} # === div.content!



