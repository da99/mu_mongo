# ~/megauni/views/Hellos_list.rb
# ~/megauni/templates/en-us/sass/Hellos_list.sass


div.col.intro! {

  h1 '{{site_title}}'
  h2 '{{site_tag_line}}'

  form.search_club_form!(:action=>"/search-clubs/", :method=>"post") {
    fieldset {
      label 'Find a club by keyword:'
      input.text(:id=>'club_keyword', :name=>'keyword', :type=>'text', :value=>'')
    }
    div.buttons {
      button.create 'Go', :onclick=>"document.getElementById('search_club_form').submit(); return false;"
    }
  } # form

  div.footer! {
    span "(c) {{copyright_year}} {{site_domain}}. Some rights reserved."
  } # the_footer
} # div.intro!


div.col.nav_bar! { 

  # div( :id=>"logo" ) { 
  #   p.title '{{site_title}}' 
  #   p.tag_line "{{site_tag_line}}" 
  # }

  ul.help {
    
    li {
      a 'Help', :href=>'/help/'
    }
    
    show_if 'logged_in?' do
      li {
        a 'Log-out', :href=>'log-out' 
      }
      li {
        a '[ Today ]', :href=>'/today/'
      }
      li {
        a '[ Account ]', :href=>'/account/'
      }
    end  
    
    show_if 'not_logged_in?' do
      li {
        a 'Log-in', :href=>'/log-in/'
      }
      li {
        a 'Create Account', :href=>'/create-account/'
      }
    end
    
  }

  show_if 'logged_in?' do
    
    p.divider 'Lives' 
    
    ul.lives {
      loop 'username_nav' do
        show_if 'selected' do
          nav_bar_li_selected '{{username}}'
        end
        show_if 'not_selected' do
          nav_bar_li_unselected '{{username}}', '{{href}}'
        end
      end
    show_if 'no_mini_nav_bar?' do
      nav_bar_li :Members, :create_life, "/create-life/", "[ Create ]"
    end
    }
  end
  
  p.divider 'Egg Timers'
  ul.to_dos {
    nav_bar_li :Timer_old, 'my-egg-timer', 'Old'
    nav_bar_li :Timer_new, 'busy-noise', 'New'
  }

  show_if 'logged_in?' do
    p.divider 'Clubs'
    ul.news {
      nav_bar_li :Clubs, :create, '/clubs/create/', '[ Create Club ]'
    }
  end

} # === div.nav_bar!


div.col.city_clubs! {
  h3 'Cities'
  loop_clubs "city_clubs"
}

div.col.political_beauty! {
  h3 'Beauty'
  div.beauty_clubs! {
    loop_clubs "beauty_clubs"
  }
  div.political_clubs! {
    loop_clubs "political_clubs"
  }
} # div.clubs

div.col.joy_clubs! { 
  h3 'Pure Joy'
  loop_clubs "joy_clubs"
}


# div.messages.messages! do
#   h4 'Random News:'
#   loop 'messages_public' do
#     div.message do
#       div.body( '{{{compiled_body}}}' )
#       div.permalink {
# 				show_if 'owner_username' do
# 					span ' by: '
# 					a('{{owner_username}}', :href=>"/life/{{owner_username}}/")
# 					br
# 				end
# 				show_if 'club_title' do
# 					span ' in: '
# 					a('{{club_title}}', :href=>"/clubs/{{club_filename}}/")
# 					br
# 				end
# 				a('Permalink', :href=>"{{href}}")
#       }
#     end
#   end
# end


# div.clubs! do
  # loop_clubs 'clubs'
# end 





