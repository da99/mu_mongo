# VIEW views/Messages_by_label.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/English/sass/Messages_by_label.sass
# NAME Messages_by_label

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
    h4 'Archives:'
    div.body {
    
      a('See all.', :href=>'/clubs/hearts/')
      
    }
  }
  
  
  mustache 'messages' do 
    div.news_post {
     div.info {
      span.published_at '{{published_at}}'
      a.permalink('PermaLink', :href=>'{{href}}' )
     }
     h4 '{{title}}'
     div.body { '{{{body}}}' }
    }
  end
  
} # === div.content!


partial('__nav_bar')

