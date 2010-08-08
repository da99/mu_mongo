

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

  def if_not mus, &blok
    if block_given?
      text "\n{{^#{mus}}}\n\n"
      yield
      text "\n{{/#{mus}}}\n\n" 
    else
      text "\n{{^#{mus}}}\n\n"
    end
  end

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

  def _fieldset_method_put
    text(capture {
      fieldset.hidden {
        _method_put
      }
    })
  end

  def input_text name, val= ''
    text(capture {
      input.text :type=>'text', :name=>name, :value=>val
    })
  end

  def label_to_name slabel
    slabel.downcase.gsub(/[^a-z0-9\_\-]/i, '')
  end

  def fieldset_input_text slabel, sname=nil, sval=''
    sname ||= label_to_name(slabel)
    text(capture {
      fieldset {
        label slabel
        input_text sname, sval
      }
    })
  end

  def fieldset_textarea slabel, name = nil, val = ''
    name ||= label_to_name(slabel)
    text( capture {
      fieldset {
        label slabel
        textarea val, :name=>name
      }
    })
  end

	def javascript_files
		(@js_files ||= []).compact.uniq
		@js_files
	end

	def add_javascript_file file_hash_or_string
		case file_hash_or_string
		when String
			javascript_files << ({
				:src=>"#{file_hash_or_string}?#{Time.now.utc.to_i}" , 
				:type=>'text/javascript'
			})
		else
			javascript_files << file_hash_or_string
		end
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
              when 'cheer'
                option 'Cheer', :value=>'cheer'
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

  # Example:
  #   checkboxes_for 'news_tags', :name=>'tags[]'
  #
  # Parameters:
  #   coll - String. Name of Array to be used in 
  #          Mustache template.
  #          Each item must be a Hash in the form of:
  #           :selected?
  #           :not_selected?
  #           :value - Optional.
  #   
  def checkboxes_for coll, &blok
    
    @checkbox ||= Class.new do 
      
      def initialize &blok
        instance_eval(&blok)
      end
      
      def text txt
        @text = txt
      end
      
      def value txt
        @value = txt
      end
      
      def name txt
        @name = txt
      end
      
      def props
        [   
          @text, 
          { :name => @name, 
            :type => 'checkbox', 
            :value => @value 
          } 
        ]
      end
      
    end
    
    span_txt, attrs = @checkbox.new(&blok).props
    
    text(capture {
      loop coll do
      
        show_if 'selected?' do
          div.box.selected {
            input( {:checked=>'checked'}.update attrs )
            span span_txt
          }
        end
        
        if_not 'selected?' do
          div.box {
            input attrs 
            span span_txt
          }
        end
        
      end # === loop
    })

  end # === checkboxes_for

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

	def form_toggles
		return if not @toggle_forms
		@toggle_forms.each { | form_id, options |
			attrs           = options.delete('options') || options.delete(:options)
			attrs['id']     = form_id
			attrs['method'] = 'post'
			field_name      = options.delete('field') || options.delete(:field)
			text(capture {
				form(attrs) {
					input(:type=>'hidden', :name=>'_method', :value=>'put')
					input(:type=>'hidden', :name=>field_name, :value=>'0')
					input(:type=>'hidden', :name=>'editor_id', :value=>'{{editor_id}}')
				}
			})
		}
	end

	def toggle_by_form form_id, field_name, attrs = {}, &blok
		@toggle_forms           ||= {}
		@toggle_forms[form_id]  = { :options => {:action=>'#nowhere'}.update(attrs), :field=>field_name }
		@toggle_form_name       = form_id
		@toggle_form_input_name = field_name
		instance_eval &blok
		clear_form_props
	end

	def href str = nil
		return @href if str == nil
		@href = str
	end

  def a_submit?
    !!@a_submit_txt
  end
  
  def a_submit_txt
    @a_submit_txt
  end

	def a_submit txt, val = :just_txt, raw_attrs = {}
    if val == :just_txt
      @a_submit_txt = txt
      return txt
    end
		attrs = {
			:href    => href || "\##{val}", 
			:onclick => %~
				$('body').addClass('toggling');
				$('\##{@toggle_form_name} input[name=\\'#{@toggle_form_input_name}\\']').val('#{val}'); 
				$(this).parents('div').first().addClass('loading');
				$('\##{@toggle_form_name}').attr('action', $(this).attr('href'));
				$('\##{@toggle_form_name}').submit();
				return false;
			~.split("\n").join(" ")
		}.update(raw_attrs)

		a( txt, attrs )
	end

  def clear_form_props
    @form_name = \
      @toggle_form_input_name = \
      @show_form = \
      @href = \
      @submit_button = \
      @radio_name = \
      @radio_value = \
      @radio_txt = \
      @a_submit_txt = \
    nil
  end

  def show_form txt
    @show_form = txt
  end

  def show_form_txt
    @show_form
  end

  def show_form?
    !!@show_form
  end
  
  def submit_button txt
    @submit_button = txt
  end

  def submit_button_txt
    @submit_button || 'Submit'
  end

  def radio name, value, txt
    @radio_name = name
    @radio_value = value
    @radio_txt = txt
  end
  
  def multi_verse_post form_id, &blok
    instance_eval &blok
    
    form_class = show_form? ? 'hidden' : ''
    form_action = href || '{{message_href}}'
    text(capture {
      
      if show_form?
        a(show_form_txt, 
            :href=>"\##{form_id}", 
            :onclick=> to_one_line( %~
              $('\##{form_id}').removeClass('hidden'); 
              $(this).remove(); 
              return false;
            ~)
        )
      end
    
      form(:id=>form_id, :action=>form_action, :method=>'post', :class=>form_class) {
        loop 'current_member_multi_verse_checkboxes' do
          h4 '{{username}}'
          checkboxes_for 'clubs' do
            text '{{title}}'
            value '{{_id}}'
            name 'clubs[]'
          end
        end
        div.buttons {
          button.submit submit_button_txt
        }
      } # === form
      
    })
    
    clear_form_props
  end

  def username_radio_form raw_form_id, &blok
    form_id = "username_radio_form_#{raw_form_id}"
    txt = capture(&blok)
    form_class = show_form? ? 'hidden' : ''
    text(capture {
      form( :id => form_id, :action => href, :method=>'post', :class=>form_class) do
        radios_for 'current_member_usernames' do
          radio 'editor_id', '{{username_id}}', '{{username}}'
        end
        div.buttons {
          button.submit submit_button_txt
        }
      end
  
      if show_form?
        div {
          a( show_form_txt, 
            :href=>"#show-form", 
            :onclick=> to_one_line(%~
              $('\##{form_id}').removeClass('hidden');
              $(this).parents('div').first().remove();
              return false;
            ~)
           )
          text txt
        }
      end
      
    })
    clear_form_props
  end

  def to_one_line txt
    txt.split("\n").map(&:strip).join(' ')
  end
  
  def radios_for mus
    yield
    loop mus do
      div.radio {
        input :type => 'radio', :name => radio_name, :value => radio_value
        span radio_txt
      }
    end
  end

  def delete_form raw_form_id, &blok
    form_id = "delete_form_#{raw_form_id}"
    txt = capture &blok
    form( :id => form_id, :action => href, :method => 'post' ) {
      _method_delete
      div.buttons {
        if a_submit?
          a.submit( 
            a_submit_txt, 
            :href=>'#delete', 
            :onclick=> to_one_line(%~
              $('##{form_id}').submit();
              return false;
            ~)
          )
          text txt
        else
          button.submit submit_button_txt
        end
      } # === div.buttons
    } # === form
  end
  
end # === module
