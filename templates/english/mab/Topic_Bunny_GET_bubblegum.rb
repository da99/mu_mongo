save_to('title') { 'Formerly: Surfer Hearts' }




div.content! { 
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
  
  if News.creator?(the_app.current_member)
    div {
      a('Create', :href=>'/news/new/')
    }
  end

  div.news_post.archives! {
    h4 'Archives By Date and Tag'
    div.body {
    
      ul {
        app_vars[:news_tags].each do |tag|
          li {
            a(tag[:filename], :href=>"/news/by_tag/#{tag[:id]}/")
          }
        end
      } # === ul
          
      ul {
        %w{ 8 4 3 2 1 }.each { |month|
          li {
            a( Time.local(2007, month).strftime('%B %Y'), :href=>"/news/by_date/2007/#{month}/" )
          }
        }
      } # === ul
      
    }
  }
  
  
  app_vars[:news].each do |heart|
    div.news_post {
     
     div.info {
      span.published_at heart[:published_at].strftime(' %b  %d, %Y ')
      a.pernalink('PermaLink', :href=>"/news/#{heart[:id]}/" )
     }
     h4 heart.title
     div.body { the_app.news_to_html( heart, :body ) }
    }
  end
  
} # === div.content!


partial('__nav_bar')


