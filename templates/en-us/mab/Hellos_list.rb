# ~/megauni/views/Hellos_list.rb
# ~/megauni/templates/en-us/sass/Hellos_list.sass

partial '__flash_msg'


div.messages.messages! do
  h4 'Random News:'
  mustache 'messages_public' do
    div.message do
      div.body( '{{{compiled_body}}}' )
      div.permalink {
        a('Permalink', :href=>"{{href}}")
      }
    end
  end
end


div.clubs! do
  mustache 'clubs' do 
    div.club {
      h4 '{{title}}'
      div.teaser '{{teaser}}'
      div.url {
      a( 'Visit.' , :href=>'{{href}}')
    }
    }
  end
end 


div.mini_nav_bar! { 

  div( :id=>"logo" ) { 
    p.site_title '{{site_title}}' 
    p.site_tag_line "{{site_tag_line}}" 
  }

  ul.help {
    
    li {
      a 'Help', :href=>'/help/'
    }
    
    mustache 'logged_in?' do
      li {
        a 'Log-out', :href=>'log-out' 
      }
      li {
        a '[ Today ]', '/today/'
      }
      li {
        a '[ Account ]', '/account/'
      }
    end  
    
    mustache 'not_logged_in?' do
      li {
        a 'Log-in', :href=>'/log-in/'
      }
      li {
        a 'Create Account', :href=>'/create-account/'
      }
    end
    
  }

  mustache 'logged_in?' do
    
    h4 'Lives' 
    
    ul.lives {
      mustache 'username_nav' do
        mustache 'selected' do
          nav_bar_li_selected '{{username}}'
        end
        mustache 'not_selected' do
          nav_bar_li_unselected '{{username}}', '{{href}}'
        end
      end
    mustache 'no_mini_nav_bar?' do
      nav_bar_li :Members, :create_life, "/create-life/", "[ Create ]"
    end
    }
  end
  
  mustache 'no_mini_nav_bar?' do
    h4 'Egg Timers'
    ul.to_dos {
      nav_bar_li :Timer_old, 'my-egg-timer', 'Old'
      nav_bar_li :Timer_new, 'busy-noise', 'New'
    }
  end

  mustache 'logged_in?' do
    h4 'Clubs'
    ul.news {
      nav_bar_li :Clubs, :create, '/clubs/create/', '[ Create Club ]'
    }
  end

} # === div.nav_bar!






