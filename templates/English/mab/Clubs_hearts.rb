



div.content! { 
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
  
  mustache 'logged_in?' do
    div {
      a('Create', :href=>'/clubs/hearts/new/')
    }
  end

  div.news_post.archives! {
    h4 'Archives By Date and Tag'
    div.body {
    
      ul {
        app_vars[:news_tags].each do |tag|
          li {
            a(tag[:filename], :href=>"/clubs/hearts/by_tag/#{tag[:id]}/")
          }
        end
      } # === ul
          
      ul {
        %w{ 8 4 3 2 1 }.each { |month|
          li {
            a( Time.local(2007, month).strftime('%B %Y'), :href=>"/clubs/hearts/by_date/2007/#{month}/" )
          }
        }
      } # === ul
      
    }
  }
  
  
  app_vars[:news].each do |heart|
    div.news_post {
     
     div.info {
      span.published_at heart[:published_at].strftime(' %b  %d, %Y ')
      a.pernalink('PermaLink', :href=>"/clubs/hearts/#{heart[:id]}/" )
     }
     h4 heart.title
     div.body { the_app.news_to_html( heart, :body ) }
    }
  end
  
} # === div.content!


partial('__nav_bar')


