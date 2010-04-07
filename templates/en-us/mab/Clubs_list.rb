# VIEW views/Clubs_list.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Clubs_list.sass
# NAME Clubs_list

div.content! { 
  
  mustache 'clubs' do 
    div.club {
      h4 '{{title}}'
      div.teaser '{{teaser}}'
      div.url {
        a( 'Visit.' , :href=>'{{href}}')
      }
    }
  end

  
} # === div.content!

partial('__nav_bar')

