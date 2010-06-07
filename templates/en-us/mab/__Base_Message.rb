
module Base_Message

  def loop_messages mustache
    text(capture { 
      loop mustache  do
        div.message {
          div.body( '{{{compiled_body}}}' )
          div.permalink {
            a('Permalink', :href=>"{{href}}")
          }
        }
      end
    })
  end

  def form_message_create raw_opts = {}
    opts = Data_Pouch.new(raw_opts, :hidden_input)
    opts.hidden_input ||= {} 
    text(capture {
    div.club_message_create! do
      h4 'Post a message:'  
      form.form_club_message_create! :method=>'POST', :action=>"/messages/" do

        opts.hidden_input.each { |k,v|
          input :type=>'hidden', :name=>k, :value=>v
        }

        show_if 'single_username?' do
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

        show_if 'multiple_usernames?' do
          fieldset {
            label 'Post as:'
            select(:name=>'owner_id') {
              loop 'multiple_usernames' do
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
    })
  end

end # === Base_Message
