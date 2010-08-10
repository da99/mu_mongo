# ~/megauni/views/Hellos_list.rb
# ~/megauni/templates/en-us/sass/Hellos_list.sass


div.col.pretension! {

  div.coming_soon! {
    strong %~ Coming Soon ~
  }

  h3.title '{{site_tag_line}}'
  
  # h4 %~ A universe lets you: ~

  ul {
    li {
      strong 'Make a Personal Encyclopedia'
      span ': You and your friends
        write in this section to record important
        moments of your life.'
    }
    
    li {
      strong 'Q & A Section'
      span ': Answer questions people throw
        at you.'
    }
    
    li {
      strong 'Magazine Section'
      span ': A place to write long stories: travel, reviews, eloquent rants, or explain why you got arrested last Saturday.'

    }

    li {
      strong 'Random Section'
      span ': Post random thoughts that cross
        your messy mind.'
    }

    li {
      strong 'Fights Section'
      span ': Discuss & debate ideas with others in a friendly fashion.'

    }
    
    li {
      strong 'Shop Section'
      span %~: Tell others about the products you love or hate.~

    }
    
    li {
      strong 'News Section'
      span ': Important things people should know.'

    }
    
    li {
      strong %~Make Requests to Friends~
      span %~: Ask friends to entertain you by posting messages.~
    }

    li {
      strong 'Predictions Section'
      span ': Record your efforts to see into the future.'

    }
    li {
      strong '"Thank You" Section'
      span ': People post a thank you note when you do something kind.'
    }

    li {
      strong %~Mind Control Made Fun & Easy~
      span %~: Bored? Let {{site_domain}} take over your mind.~
    }
  # } # === ul

  # # h4 %~ Other features: ~

  # ul {
    
    li {
      strong %~Multiple Lives~
      span %~: Create different usernames for your work life, home life, babies, pets, fantasy life, etc.~
    }
    
    li {
      strong %~No Popularity Contests~
      span %~: The total number of followers is kept secret to avoid spam and publicity hounds.~
    }

    li {
      strong %~Re-posting for easy sharing.~
      span %~: Find something you like in someone else's universe? You can re-post it easily with your own custom intro.~
    }

    
  } # === ul


} # === div


div.col.middle! {
  div.intro! {

    # h1 '{{site_title}}'
    # h2 '{{site_tag_line}}'

    form.search_club_form!(:action=>"/club-search/", :method=>"post") {
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


  div.nav_bar! { 

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
        # li {
        #   a '[ Today ]', :href=>'/today/'
        # }
        li {
          a '[ Account ]', :href=>'/account/'
        }
      end  
      
      show_if 'not_logged_in?' do
        li {
          a 'Log-in', :href=>'/log-in/'
        }
        # li {
        #   a 'Create Account', :href=>'/create-account/'
        # }
      end
      
    }

    show_if 'logged_in?' do
      
      div.divider 'Lives' 
      
      ul.lives {
        loop 'username_nav' do
          show_if 'selected?' do
            nav_bar_li_selected '{{username}}'
          end
          show_if 'not_selected?' do
            nav_bar_li_unselected '{{username}}', '{{href}}'
          end
        end
      show_if 'not_mini_nav_bar?' do
        nav_bar_li :Members, :create_life, "/create-life/", "[ Create ]"
      end
      }
    end
    
    div.divider 'Egg Timers'
    
    ul.to_dos {
      nav_bar_li :Timer_old, 'my-egg-timer', 'Old'
      nav_bar_li :Timer_new, 'busy-noise', 'New'
    }

    show_if 'logged_in?' do
      div.divider 'Clubs'
      ul.news {
        nav_bar_li :Clubs, :create, '/club-create/', '[ Create Club ]'
      }
    end

    div.divider 'Old Stuff'
    
    ul.old_clubs {
      loop 'old_clubs' do
        li { a('{{title}}', :href=>'{{href}}') }
      end
    }

  } # === div.nav_bar!


} # === div.col


show_if 'city_clubs?' do
  div.col.city_clubs! {
    h3 'Cities'
    loop_clubs "city_clubs"
  }
end

show_if 'political_beauty?' do
  div.col.political_beauty! {
    h3 'Beauty'
    div.beauty_clubs! {
      loop_clubs "beauty_clubs"
    }
    div.political_clubs! {
      loop_clubs "political_clubs"
    }
  } # div.clubs
end

show_if 'joy_clubs?' do
  div.col.joy_clubs! { 
    h3 'Pure Joy'
    loop_clubs "joy_clubs"
  }
end

show_if 'random_clubs?' do
  div.col.random_clubs! { 
    h4 'An example of a universe:'
    loop_clubs "random_clubs" do
			meta
		end
  }
end


# div.messages.messages! do
#   h4 'Random News:'
#   loop 'messages_public' do
#     div.message do
#       div.body( '{{{compiled_body}}}' )
#       div.permalink {
#         show_if 'owner_username' do
#           span ' by: '
#           a('{{owner_username}}', :href=>"/life/{{owner_username}}/")
#           br
#         end
#         show_if 'club_title' do
#           span ' in: '
#           a('{{club_title}}', :href=>"/clubs/{{club_filename}}/")
#           br
#         end
#         a('Permalink', :href=>"{{href}}")
#       }
#     end
#   end
# end


# div.clubs! do
  # loop_clubs 'clubs'
# end 





