# VIEW views/Members_lives.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Members_lives.sass
# NAME Members_lives

  
	
div.content! { 

  div.lives_create! { 
    h4 'Post message'

    form :id=>'form_lives_create', :action=>'/messages/', :method=>'post' do
    
      input :type=>'hidden', :name=>'category', :value=>'tweet'
      input :type=>'hidden', :name=>'username', :value=>'{{current_member_username}}'

      fieldset {
        textarea '', :name=>'body'
      }

      fieldset {
        label 'Privacy'
        select :name=> 'privacy' do
          option 'Friends Only.', :value=>'friends', :selected=>'selected'
          option 'Public.', :value=>'public'
          option 'Just for me.', :value=>'private'
        end
      }

      fieldset {
        label 'Labels'
        input.text :name=>'private_labels', :value=>'', :type=>'text'
      }

      div.buttons {
        button 'Save'
      }

    end
    
  } # === div.lives_create!


  div.newspaper! {
    show_if('no_newspaper?') {
      a('You have not subscribed to anyone\'s life.')
    }
    show_if 'newspaper?' do  
      h4 'The latest from your subscriptions:'
      show_if 'newspaper' do
        div.message do
          div.body( '{{{compiled_body}}}' )
          div.permalink {
            a('Permalink', :href=>"{{href}}")
          }
        end
      end
    end
  } # === div.newspaper!
	
} # === div.content! 

partial('__nav_bar')

