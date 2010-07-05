require 'models/Data_Pouch'

module Base_Message

  def loop_messages mustache, opts = {}
    options = Data_Pouch.new(opts, :include_meta)
    text(capture { 
      loop mustache  do
        div.message {
          if options.include_meta
            div.meta {
              strong '{{message_model_in_english}}'
            }
          end
          div.body( '{{{compiled_body}}}' )
          div.permalink {
            a('Permalink', :href=>"{{href}}")
          }
        }
      end
    })
  end

  def form_message_create raw_opts = {}
    
    opts = Data_Pouch.new(raw_opts, :hidden_input, :title, :input_title, :models)
    opts.hidden_input ||= {} 
    message_model = opts.hidden_input[:message_model]
    english = [ 
      ['random'   , 'Random Thought']      ,
      ['news'     , 'Important News']      ,
      ['question' , 'Question']            ,
      ['fact'     , 'Encyclopedia Chapter'],
      ['e_chapter', 'Encyclopedia Chapter'],
      ['chapter'  , 'Encyclopedia Chapter'],
      ['story'    , 'Story']               ,
      ['fight'    , 'Fight']               ,
      ['complaint', 'Complaint']           ,
      ['praise', 'Praise & Cheer']           ,
      ['debate'   , 'Friendly Debate']     ,
      ['plea'      , 'Request']                    ,
      ['buy'       , 'Product Recommendation']     ,
      ['prediction', 'Prediction']
    ]
    models = opts.models || english.map(&:first)
    add_javascript_file '/js/vendor/jquery-1.4.2.min.js'
    add_javascript_file '/js/pages/Megauni_Base.js'
    text(capture {
    div.club_message_create! do
      
      form.form_club_message_create! :method=>'post', :action=>"/messages/" do

        if opts.title
          h4 opts.title
        else
          h4 'Post a message:'
        end

        if not message_model
          fieldset {
						select(:name=>'message_model') {
              english.each do |val, name|
                option( name, :value=>val ) if models.include?(val)
              end
            }
          }
        end
      
				fieldset.hidden {
					input :type=>'hidden', :name=>'body_images_cache', :value=>''

					opts.hidden_input.each { |k,v|
						input :type=>'hidden', :name=>k, :value=>v
					}

					show_if 'single_username?' do
						input :type=>'hidden', :name=>'username', :value=>'{{first_username}}'
					end

					if message_model
						input :type=>'hidden', :name=>'message_model', :value=>message_model
					end
				}

        if opts.input_title
          fieldset_input_text 'Title:'
        end
        
        fieldset {
          textarea '', :name=>'body'
        }

        # fieldset {
        #   label "Labels (Separate each with a comma.)"
        #   input.text :type=>'text', :name=>'public_labels', :value=>''
        # }

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

        # fieldset {
        #   label 'Important?'
        #   select(:name=>'important') {
        #     option "No. It can wait.", :value=>''
        #     option "Yes", :value=>'true'
        #   }
        # } 
        
        div.buttons {
          button.create 'Save', :onclick=>"if(window['Form_Submitter']) Form_Submitter.submit(this); return false;"
        }
      end
    end
    })
  end

end # === Base_Message
