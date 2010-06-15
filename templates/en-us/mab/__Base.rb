

module Base
  
  def mustache mus, &blok
    if block_given?
      text "\n{{\##{mus}}}\n\n"
      yield
      text "\n{{/#{mus}}}\n\n" 
    else
      text "\n{{#{mus}}}\n\n"
    end
  end
  alias_method :show_if, :mustache
  alias_method :loop,    :mustache

  def _method_delete
    text(capture { 
      input :type=>'hidden', :name=>'_method', :value=>'delete' 
    })
  end
  
  def _method_put
    text(capture { 
      input :type=>'hidden', :name=>'_method', :value=>'put' 
    })
  end

  def the_app
    @the_app = Class.new {
      def method_missing *args
        return self
      end
      def to_s
        ''
      end
    }.new
 
  end
  alias_method :app_vars, :the_app

  def partial( raw_file_name )
    calling_file = caller[0].split(':').first
    calling_dir  = File.dirname(calling_file)
    file_name    = File.expand_path(File.join(calling_dir,raw_file_name)).to_s
    file_name += '.rb' if !file_name['.rb']
    
    # Find template file.
    partial_filepath = if File.exists?(file_name)
       file_name 
    end

    if !partial_filepath
      raise "Partial template file not found: #{file_name}"
    end
    
    # Get & Render the contents of template file.
    text( 
      capture { 
        eval( File.read(partial_filepath), nil, partial_filepath, 1  )
      } 
    )
    ''
  end # === partial
  
  
  
  def form_create_message mess_mod_arr
    mustache 'show_form_create_message?' do
      form.form_message_create!(:action=>'/messages/', :method=>'post') {
        
        input :type=>'hidden', :name=>'message_id', :value=>'{{message_id}}'
        input :type=>'hidden', :name=>'privacy', :value=>'public'
        mustache 'single_username?' do
          input :type=>'hidden', :name=>'username', :value=>'{{first_username}}'
        end
        
        fieldset {
          select(:name=>'message_model') {
            mess_mod_arr.each do |mod|
              case mod
              when 'comment'
                option 'Comment', :value=>'comment'
              when 'regular_comment'
                option 'Regular Comment', :value=>'comment'
              when 'fulfill'
                option 'Fulfill Request', :value=>'fulfill'
              when 'tip'
                option 'Tips/Advice', :value=>'tip'
              when 'question'
                option 'Question?', :value=>'question'
              when 'praise'
                option 'Praise', :value=>'praise'
              when 'complain', 'complaint'
                option 'Complaint', :value=>'complaint'
              when 'idea'
                option 'Idea', :value=>'idea'
              when 'answer'
                option 'Answer', :value=>'answer'
              else
                raise "Unknown message model: #{mod.inspect}"
            end
            end
          }
        }

        fieldset {
          textarea('', :name=>'body')
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
        
        div.buttons {
          button.create 'Save'
        }

      } # === form
    end
  end

  def checkboxes_for coll, orig_attrs, &blok
    @checkbox ||= Class.new do 
      attr_reader :results
      def initialize &blok
        @results = instance_eval(&blok)
      end
      def checkbox *args
        @results =  args
      end
    end
    
    span_txt, attrs = @checkbox.new(&blok).results
    attrs.update orig_attrs
    attrs[:type] = 'checkbox'
    attrs[:value] = "{{#{attrs[:value]}}}" if attrs[:value]
    
    txt = capture {
      mustache coll do
        mustache 'selected?' do
          div.box.selected {
            input( {:checked=>'checked'}.update attrs )
            span "{{#{span_txt}}}"
          }
        end
        mustache 'not_selected?' do
          div.box {
            input attrs 
            span "{{#{span_txt}}}"
          }
        end
      end
    }

    text txt
  end

  def menu_for coll, select_attrs={}, &blok
    @option_class = Class.new do
      attr_reader :results
      def initialize &blok
        instance_eval(&blok)
      end
      def option *args
        @results = args
      end
    end
    
    opt_txt, attrs = @option_class.new(&blok).results
    attrs[:value] = "{{#{attrs[:value]}}}"
    
    txt = (capture { 
      select(select_attrs) {
        mustache coll do
          mustache 'selected?' do
            option "{{#{opt_txt}}}", {:selected=>'selected'}.update(attrs)
          end 
          mustache 'not_selected?' do
            option "{{#{opt_txt}}}"
          end
        end
      }
    })
    text txt
  end

  def nav_bar_li_selected txt
    text(capture {
      li.selected { span "< #{txt} >" }
    })
  end

  def nav_bar_li_unselected txt, href
    text(capture {
      li {
        a " #{txt} ", :href=>href
      }
    })
  end

  def nav_bar_li *args
    case args.size
    when 2, 3
      controller, raw_shortcut, txt = args
      shortcut      = raw_shortcut.gsub(%r!\A/|/\Z!,'').gsub(/[^a-zA-Z0-9\_]/, '_')
      template_name = "#{controller}_#{shortcut}".to_sym
      txt      ||= shortcut.to_s.capitalize
    when 4
      controller, action, raw_shortcut, txt = args
      template_name = "#{controller}_#{action}".to_sym
    end
    
    prefix = case controller
               when :Topic, :Topics
                 '/clubs'
               else
                 ''
               end
                 
    href     = shortcut == 'home' ? '/' : File.join('/', prefix, raw_shortcut, '/')
    if self.template_name.to_s === template_name.to_s
      nav_bar_li_selected txt
    else
      nav_bar_li_unselected txt, href
    end
  end

  def nav_bar raw_shortcut, txt = nil
    shortcut = raw_shortcut.gsub(/[^a-zA-Z0-9\_]/, '_')
    path = shortcut == 'home' ? '/' : "/#{raw_shortcut}/"
    txt ||= shortcut.to_s.capitalize
    text(capture {
      mustache "selected_#{shortcut}" do
        li.selected { span txt }
      end
      mustache "unselected_#{shortcut}" do
        li {
          a txt, :href=>"#{path}"
        }
      end
    })
  end


end # === module
