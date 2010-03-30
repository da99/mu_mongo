# VIEW views/Clubs_by_id.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/English/sass/Clubs_by_id.sass
# NAME Clubs_by_id

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

  div.news_post.label_archives! {
    h4 'Archives By Label'
    div.body {
    
      ul {
        mustache 'public_labels' do 
          li {
            a( '{{filename}}', :href=>"/clubs/hearts/by_label/{{filename}}/")
          }
        end
      } # === ul
          
    }
  }

  div.news_post.date_archives! {
    h4 'Archives By Date'
    div.body {
    
      ul {
        mustache 'months' do
          li {
            a( '{{text}}', :href=>"{{href}}" )
          }
        end
      } # === ul
      
    }
  }
  
  
} # === div.content!


partial('__nav_bar')
