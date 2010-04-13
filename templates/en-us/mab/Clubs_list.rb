# VIEW views/Clubs_list.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Clubs_list.sass
# NAME Clubs_list

  
  div.clubs.my_clubs! do
    mustache 'my_clubs' do 
      div.club {
        h4 {
          a '{{title}}', :href=>'{{href}}'
        }
        div.teaser '{{teaser}}'
      }
    end
  end

  div.clubs.clubs! do
    mustache 'clubs' do 
      div.club {
        h4 {
          a '{{title}}', :href=>'{{href}}'
        }
        div.teaser '{{teaser}}'
      }
    end
  end

  


  partial('__mini_nav_bar')
