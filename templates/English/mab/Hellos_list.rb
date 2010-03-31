# ~/megauni/views/Hellos_list.rb
# ~/megauni/templates/English/sass/Hellos_list.sass


div.content! do
  
  partial '__flash_msg'

  div.why_are_you_bored! {
    
    div.club_messages! do
      h4 'News:'
      p.waves " ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"
      mustache 'messages_public' do
        div.message {
          div.body( '{{{compiled_body}}}' )
          div.permalink {
            a('Permalink', :href=>"{{href}}")
          }
        }
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

