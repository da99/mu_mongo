require 'models/Data_Pouch'
require 'models/Config_Switches'

module Base_Message

  def loop_messages_with_opening mess, h4_txt, empty_txt = nil
    text(capture {

      show_if("#{mess}?") {
        h4 h4_txt
      }

      if !!empty_txt
        show_if("no_#{mess}?"){
          div.empty_msg empty_txt
        }
      end

      loop_messages mess
    })
  end

  def loop_messages coll_name, &blok
    
    opts = Config_Switches.new {
      allow :meta, on
      allow :permalink, on
      exec( &blok ) if blok
    }

    text(capture { 
      loop coll_name  do
        div.message {
          
          show_if 'suggest?' do
            show_if('accepted?') {
              div.accepted { span 'Accepted' }
            }
            show_if('declined?') {
              div.declined { span 'Declined' }
            }
          end
        
          show_if 'title' do
            strong.title '{{title}}'
          end

          div.body( '{{{compiled_body}}}' )
          
          div.owner {
            span 'Author: '
            show_if 'owner?' do
              span 'you'
            end
            show_if 'not_owner?' do
              a('{{owner_username}}', :href=>'{{owner_href}}')
            end
              
          }

          show_if 'has_parent_message?' do
            show_if 'suggest?' do
              show_if 'parent_message_owner?' do
                div.toggle_suggest {
                  toggle_by_form('toggle_message_accept', :owner_accept) {
                  
                    action '{{href}}'  
                    
                    show_if 'not_accepted?' do
                      a_submit('Accept', Message::ACCEPT)
                    end
                    
                    show_if 'pending?' do
                      span ' or '
                    end
                    
                    show_if 'not_declined?' do
                      a_submit('Decline', Message::DECLINE)
                    end
                    
                    show_if 'not_pending?' do
                      span ' or '
                      a_submit('I don\'t know.', Message::PENDING)
                    end
                    
                  }
                }
              end
            end
          end

          show_if 'has_parent_message?' do
            div.permalink {
              a('reply', :href=>"{{href}}")
            }
          end

          if opts.permalink?
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

  def post_message raw_opts = {}, &blok
    
    opts = Config_Switches.new {
      allow :input_title, off
      strings :title, :css_class
      array :models
      hash :hidden_input
      exec &blok
    }
    
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
      ['suggest', 'Suggestion'],
      ['debate'   , 'Friendly Debate']     ,
      ['plea'      , 'Request']                    ,
      ['buy'       , 'Product Recommendation']     ,
      ['prediction', 'Prediction']
    ]
    models = opts.models? ? opts.models : english.map(&:first)
    div_attrs = {}
    if opts.css_class?
      div_attrs[:class] = opts.css_class
    end
    add_javascript_file '/js/vendor/jquery-1.4.2.min.js'
    add_javascript_file '/js/pages/Megauni_Base.js'
    text(capture {
    div.club_message_create!(div_attrs) do
      
      form_post 'form_club_message_create', '/messages/' do

        if opts.title?
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
          input_hidden 'body_images_cache', ''
          input_hidden 'return_url'       , '{{url}}'
          input_hidden 'privacy', 'public'
          if message_model
            input_hidden 'message_id', '{{message_id}}'  
            input_hidden 'message_model', message_model 
          end
          
          opts.hidden_input.each { |k,v|
            input_hidden k, v
          }

          show_if 'single_username?' do
            input_hidden 'username', '{{first_username}}'
          end

          if message_model
          end
        }

        if opts.input_title?
          fieldset 'Title:', ''
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

        button_create 'Save'
      end
    end
    })
  end

end # === Base_Message
