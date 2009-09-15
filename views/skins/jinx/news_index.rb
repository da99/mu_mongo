save_to('title') { 'Formerly: Surfer Hearts' }


partial('__nav_bar')


div.content! { 
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
  
	if the_app.is_creator?
		div {
			a('Create', :href=>'/news/new/')
		}
	end

  div.heart_link.archives! {
    h4 'Archives By Date and Tag'
    div.body {
    
      ul {
        app_vars[:news_tags].each do |tag|
          li {
            a(tag[:filename], :href=>"/hearts/by_tag/#{tag[:id]}")
          }
        end
      } # === ul
          
      ul {
        %w{ 8 4 3 2 1 }.each { |month|
          li {
            a( Time.local(2007, month).strftime('%B %Y'), :href=>"/hearts/by_date/2007/#{month}/" )
          }
        }
      } # === ul
      
    }
  }
  
  
  app_vars[:news].each do |heart|
    div.heart_link {
     
     div.info {
      span.published_at heart[:published_at].strftime('%b  %d, %Y ')
      a.pernalink('PermaLink', :href=>"/heart_link/#{heart[:id]}" )
     }
     h4 heart.title
     div.body { heart.body }
    }
  end
  
} # === div.content!










