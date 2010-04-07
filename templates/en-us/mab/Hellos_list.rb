# ~/megauni/views/Hellos_list.rb
# ~/megauni/templates/en-us/sass/Hellos_list.sass


div.content! do
  
  partial '__flash_msg'

  div.why_are_you_bored! {
    
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
    
    div.messages do
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

    # form.create_why_are_you_bored!( :action=> '/club/bored/messages', :method => 'post') {
    #   fieldset {
    #     textarea ''
    #   }
    #   div.buttons {
    #     button.create 'Submit', :class => 'submit'
    #   }
    # }

  }


end

partial('__nav_bar')
__END__

        li "Stay connected with co-workers, friends and relatives."
        li "Less annoying then FaceBook. More useful than Twitter."

