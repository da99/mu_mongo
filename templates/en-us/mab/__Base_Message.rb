require 'models/Data_Pouch'

module Base_Message
  
  def loop_messages_with_opening mess, h4_txt, empty_txt = nil, opts = {}
    text(capture {

      show_if("#{mess}?") {
        h4 h4_txt
      }

      if !!empty_txt
        show_if("no_#{mess}?"){
          div.empty_msg empty_txt
        }
      end

      loop_messages mess, opts
    })
  end

  def loop_messages mustache, raw_opts = {}
    opts = {:include_meta => false, :include_permalink => true}.update(raw_opts)
    options = Data_Pouch.new(opts, :include_meta, :include_permalink)
    
    text(capture { 
      loop mustache  do
        div.message {
          
          if options.include_meta
            # div.meta {
            #   strong ''
            # }
          end
        
          show_if 'title' do
            strong.title '{{title}}'
          end

          div.body( '{{{compiled_body}}}' )
          
          if options.include_permalink
            show_if 'has_parent_message?' do
              div.permalink {
                strong '{{message_model_in_english}}'
                span ' for '
                a('this', :href=>"{{parent_message_href}}")
              }
            end
            show_if 'parent_message?' do
              div.permalink {
                show_if 'logged_in?' do
                  a('Reply', :href=>"{{href}}")
                  span " to this "
                  strong " {{message_model_in_english}} "
                end
                show_if 'not_logged_in?' do
                  a('link to this {{message_model_in_english}}', :href=>'{{href}}')
                end
              }
            end
          end
        }
      end
    })
  end

  def form_message_create raw_opts = {}
    
    opts = Data_Pouch.new(raw_opts, :css_class, :hidden_input, :title, :input_title, :models)
    opts.hidden_input ||= {} 
    message_model = opts.hidden_input[:message_model]
    english = [ 
      ['random'   , 'Random Thought']      ,
      ['news'     , 'Important News']      ,
      ['question' , 'Question']            ,
      ['fact'     , 'Encyclopedia Chapter'],
      ['e_chapter', 'Encyclopedia Chapter'],
      ['e_quote', 'Quote'],
      ['chapter'  , 'Encyclopedia Chapter'],
      ['story'    , 'Story']               ,
      ['fight'    , 'Fight']               ,
      ['complaint', 'Complaint']           ,
      ['cheer', 'Praise & Cheer']           ,
      ['jeer', 'Criticize']           ,
      ['debate'   , 'Friendly Debate']     ,
      ['plea'      , 'Request']                    ,
      ['buy'       , 'Product Recommendation']     ,
      ['prediction', 'Prediction']
    ]
    models = opts.models || english.map(&:first)
    div_attrs = {}
    if opts.css_class
      div_attrs[:class] = opts.css_class
    end
    add_javascript_file '/js/vendor/jquery-1.4.2.min.js'
    add_javascript_file '/js/pages/Megauni_Base.js'
    text(capture {
    div.club_message_create!(div_attrs) do
      
      form.form_club_message_create!(:method=>'post', :action=>"/messages/") do

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
					input :type=>'hidden', :name=>'body_images_cache', :value => ''
					input :type=>'hidden', :name=>'return_url', :value => '{{url}}'

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
