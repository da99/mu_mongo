# VIEW views/Clubs_list.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Clubs_list.sass
# NAME Clubs_list

show_if 'your_clubs?' do
  div.clubs.my_clubs! {
    loop 'your_clubs' do 
      div.club {
        h4 {
          a '{{title}}', :href=>'{{href}}'
        }
        div.teaser '{{teaser}}'
      }
    end
  }
end

div.clubs.clubs! do
  loop 'clubs' do 
    div.club {
      h4 {
      a '{{title}}', :href=>'{{href}}'
    }
    div.teaser '{{teaser}}'
    }
  end
end

  


  partial('__mini_nav_bar')
