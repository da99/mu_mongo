# VIEW views/Clubs_by_id.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_by_id.sass
# NAME Clubs_by_id


h3 '{{club_title}}' 

div.teaser '{{club_teaser}}'

club_nav_bar(__FILE__)

mustache 'logged_in?' do
  
  div.club_message_create! do
    h4 'Post a message:'  
    form.form_club_message_create! :method=>'POST', :action=>"/messages/" do

      input :type=>'hidden', :name=>'club_filename', :value=>'{{club_filename}}'
      input :type=>'hidden', :name=>'privacy', :value=>'public'

      mustache 'single_username?' do
        input :type=>'hidden', :name=>'username', :value=>'{{first_username}}'
      end

      fieldset {
        select(:name=>'message_model') {
          option "Comment",     :value=>'comment'
          option "Story",       :value=>'story'
          option "Humorous ;)", :value=>'joke'
          option "Question?",   :value=>'question'
          option "Request",     :value=>'plea'
          option "Brainstorm",  :value=>'brainstorm'
          # option "Event",       :value=>'event'
          option "Complain!",   :value=>'complaint'
          option "Product",     :value=>'product'
        }
      } 

      fieldset {
        textarea '', :name=>'body'
      }

      fieldset {
        label "Labels (Separate each with a comma.)"
        input.text :type=>'text', :name=>'public_labels', :value=>''
      }

      mustache 'multiple_usernames?' do
        fieldset {
          label 'Post as:'
          select(:name=>'owner_id') {
            mustache 'multiple_usernames' do
              option '{{username}}', :value=>'{{username}}'
            end
          }
        }
      end

      fieldset {
        label 'Important?'
        select(:name=>'important') {
          option "No. It can wait.", :value=>''
          option "Yes", :value=>'true'
        }
      } 
      
      div.buttons {
        button.create 'Save'
      }
    end
  end
  
end # logged_in?


div.club_messages! do
  mustache 'no_messages_latest' do
    div.empty_msg 'No messages yet.'
  end
  mustache 'messages_latest' do
    div.message {
      div.body( '{{{compiled_body}}}' )
      div.permalink {
        a('Permalink', :href=>"{{href}}")
      }
    }
  end
end

