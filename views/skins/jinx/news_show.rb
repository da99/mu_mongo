save_to('title') { app_vars[:news][:title] }




div.content! { 
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
  

  div.news_post {
   
   div.info {
    span.published_at app_vars[:news][:published_at].strftime('%b  %d, %Y')
   }
   h4 app_vars[:news][:title]
   div.body { app_vars[:news].body_html }

   if !app_vars[:news_tags].empty?
		 div.tags {
			if app_vars[:news].updator?(the_app.current_member)
				a('Edit', :href=>"#{the_app.request.path_info}edit/")
			end
				p.title 'Tags:'
				ul {
					app_vars[:news_tags].each do |tagging|
						li {
							a(tagging.tag.filename, :href=>"/news/by_tag/#{tagging.tag[:id]}/")
						}
					end
				}
			
		 }
	 end
  }
  
} # === div.content!


partial('__nav_bar')

