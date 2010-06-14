require 'models/Data_Pouch'

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
    
    opts = Data_Pouch.new(raw_opts, :hidden_input, :title)
    opts.hidden_input ||= {} 
    message_model = opts.hidden_input[:message_model]
    text(capture {
    div.club_message_create! do
      
      form.form_club_message_create! :method=>'POST', :action=>"/messages/" do

        if opts.title
          label opts.title
        else
          label 'Post a message:'
        end
      
        opts.hidden_input.each { |k,v|
          input :type=>'hidden', :name=>k, :value=>v
        }

        show_if 'single_username?' do
          input :type=>'hidden', :name=>'username', :value=>'{{first_username}}'
        end

        if message_model
          input :type=>'hidden', :name=>'message_model', :value=>message_model
        else
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
        end

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
