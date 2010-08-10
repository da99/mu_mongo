
module Concise_Attrs
  def attr_concise *fields
    this = self
    class_eval {
      fields.each { |fld|
        eval %~
          def #{fld} *args
            return @#{fld} if args.empty?
            return @#{fld} = args.first if args.size === 1
            @#{fld} = args
          end
            
          def #{fld}?
            !!@#{fld}
          end
        ~
      }
    }
  end 
end # === module Concise_Attrs


module Base_Forms

  extend Concise_Attrs
  attr_reader :as_type
  attr_concise :action, :show_target

  %w{ radios check_boxes menu }.each { |type|
    eval %~
      def as_#{type} 
        @as_type = :#{type}
      end

      def as_#{type}?
        @as_type == :#{type}
      end
    ~

  }

  def a_show txt, &blok
    context = self
    a(
      txt, 
      :href => "#show-#{context.show_target}",
      :onclick => js {
        id(context.show_target).remove_class('hidden')
        this.parent('div').remove
        return_false
      } 
    )
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

  def fieldset_hidden &blok
    text(capture {
      fieldset.hidden {
        instance_eval &blok
      }
    })
  end

  def input_hidden name, value = ''
    input :type=>'hidden', :name=>name, :value=>value
  end

  def input_text name, val= ''
    text(capture {
      input.text :type=>'text', :name=>name, :value=>val
    })
  end

  def label_to_name slabel
    slabel.downcase.gsub(/[^a-z0-9\_\-]/i, '')
  end

  def button_create txt = 'Save'
    div.buttons {
      button.create txt, :onclick => js! { parent_form.submit }
    }
  end

  def button_submit txt = 'Save'
    div.buttons {
      button.submit txt, :onclick => js! { parent_form.submit }
    }
  end

  def button_update txt = 'Update'
    div.buttons {
      button.update txt, :onclick => js! { parent_form.submit }
    }
  end
  
	def a_submit txt, href = nil
    context = self
		a( 
      txt, 
			:href    => "#save", 
			:onclick => js {
				element(context.show_target) {
				  parents('div').add_class('loading')
          attr('action', context.action )
				  submit();
        }
				return_false
       }
    )
	end

  def fieldset *args, &blok
    case args.size
    when 0
      return super(*args, &blok)
    when 2
      label_txt = args.first
      name      = label_to_name(args.first)
      val       = args.last
    when 3
      label_txt, name, val = args
    else
      raise ArgumentError, "Argument size can only be 0, 2, or 3: #{args.inspect}"
    end
    
    fieldset.text {
      label label_txt
      input_text name, val
    }
  end

  # Uses a TEXTAREA instead of an INPUT[type=text].
  def fieldset! *args
    case args.size
    when 2
      label_txt = args.first
      name      = label_to_name(args.first)
      val       = args.last
    when 3
      label_txt, name, val = args
    else
      raise ArgumentError, "Argument size can only be 0, 2, or 3: #{args.inspect}"
    end
    
    fieldset.textarea {
      label label_txt
      textarea( val || '', :name=>name )
    }
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

  def clear_form_props
    @form_name              = \
    @toggle_form_input_name = \
    @show_form              = \
    @href                   = \
    @submit_button          = \
    @radio_name             = \
    @radio_value            = \
    @radio_txt              = \
    @a_submit_txt           = \
    @show_target            = \
    @action                 = \
    @as_type                = \
    @show_content           = \
    nil
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

  def radio name, value, txt
    @radio_name = name
    @radio_value = value
    @radio_txt = txt
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
					fieldset_hidden {
            _method_put    
            input_hidden field_name, '0'
            input_hidden 'editor_id', '{{editor_id}}'
          }
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
  
  def form_wrapper form_id
    show_target form_id
    yield
    text(show) if show?
    clear_form_props
  end

  def form_post form_id, action
    form_wrapper(form_id) {
      form :id=>form_id, :action=>action, :method=>'post' do
        yield
      end
    }
  end

  def show
    if block_given?
      @show_content = capture { 
        div {
          yield 
        }
      }
    else
      @show_content
    end
  end
  
  def show?
    !!@show_content
  end

  def post_to_universes raw_form_id, &blok
    form_id    = "post_to_universes_#{raw_form_id}"
    
    text(capture {
      
      form_wrapper(form_id) {
      
        txt        = capture(&blok)
        form_class = show? ? 'hidden' : ''
        
        form(:id=>form_id, :action=>action, :method=>'post', :class=>form_class) {
      
          loop 'current_member_multi_verse_checkboxes' do
            h4 '{{username}}'
            checkboxes_for 'clubs' do
              text '{{title}}'
              value '{{_id}}'
              name 'clubs[]'
            end
          end
  
          text txt
          
        } # === form
        
      } # === form_wrapper
      
    })
    
  end

  def post_to_username raw_form_id, &blok
    form_id    = "username_radio_form_#{raw_form_id}"

    text(capture {
      form_wrapper(form_id) {
      
        txt        = capture(&blok)
        form_class = show? ? 'hidden' : ''
        
        form( :class => form_class, :id => form_id, :action => action, :method=>'post') do
          if as_radios?
            radios_for 'current_member_usernames' do
              radio 'editor_id', '{{username_id}}', '{{username}}'
            end
          else
            raise "Unknown type: #{as_type.inspect}"
          end
        
          text txt
        end
  
      }
      
    })
    
  end

  def delete_form raw_form_id, &blok
    form_id = "delete_form_#{raw_form_id}"
    form_wrapper form_id do
      txt = capture &blok
      form( :id => form_id, :action => action, :method => 'post' ) {
        fieldset_hidden {
          _method_delete
        }
        text txt
      } # === form
    end
  end
  
end # === module Base_Forms
