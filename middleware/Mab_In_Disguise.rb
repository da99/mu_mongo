
class Mab_In_Disguise
  
  def self.compile_all
		Dir.glob("templates/*/mab/*.rb").each { |mab_file|
			next if mab_file['layout.rb']
			mab_dir       = File.dirname(mab_file)
			layout_file   = File.join(mab_dir, 'layout.rb')
			file_basename = File.basename(mab_file)
			is_partial    = file_basename[/^__/]
			html_file     = mab_file.sub('mab/', 'mustache/').sub('.rb', '.html')
			template_name = file_basename.sub('.rb', '').to_sym
			
			content       = if is_partial
												Markaby::Builder.new(:template_name=>template_name) { 
													eval( File.read(mab_file), nil, mab_file , 1)
												}
											else
												Markaby::Builder.new(:template_name=>template_name) { 
													eval(
														File.read(layout_file).sub("{{content_file}}", file_basename),
														nil, 
														layout_file, 
														1
													)
												}
											end
			
      puts "Writing: #{html_file}"
      File.open(html_file, 'w') do |f|
        f.write content
      end
		}
  end

	def self.compile file_name = nil
		vals = {}
		Dir.glob("templates/*/mab/*.rb").each { |mab_file|
			next if mab_file['layout.rb']
			mab_dir       = File.dirname(mab_file)
			layout_file   = File.join(mab_dir, 'layout.rb')
			file_basename = File.basename(mab_file)
			is_partial    = file_basename[/^__/]
			html_file     = mab_file.sub('mab/', 'mustache/').sub('.rb', '.html')
			template_name = file_basename.sub('.rb', '').to_sym
			
			content       = if is_partial
												Markaby::Builder.new(:template_name=>template_name) { 
													eval( File.read(mab_file), nil, mab_file , 1)
												}
											else
												Markaby::Builder.new(:template_name=>template_name) { 
													eval(
														File.read(layout_file).sub("{{content_file}}", file_basename),
														nil, 
														layout_file, 
														1
													)
												}
											end
			
			vals[mab_file] = [html_file, content]
		}

		if file_name 
			if !vals[file_name]
        raise ArgumentError, "Template not found: #{file_name}. Available templates: #{vals.keys.join(', ')}"
      end
      vals[file_name].last
    else
			vals
    end
	end
  
end # === Mab_In_Disguise



require 'markaby'

class Ignore_Everything
  def method_missing *args
    return self
  end
	def to_s
		''
	end
end

class Markaby::Builder
  
  set(:indent, 1)

  def _input_put_method
    text(capture { 
      input :type=>'hidden', :name=>'method', :value=>'_put' 
    })
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
        mustache 'selected' do
          div.box.selected {
            input( {:checked=>'checked'}.update attrs )
            span "{{#{span_txt}}}"
          }
        end
        mustache 'not_selected' do
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
          mustache 'selected' do
            option "{{#{opt_txt}}}", {:selected=>'selected'}.update(attrs)
          end 
          mustache 'not_selected' do
            option "{{#{opt_txt}}}"
          end
        end
      }
    })
    text txt
  end

  def nav_bar_li controller, raw_shortcut, txt = nil
		shortcut      = raw_shortcut.gsub(/[^a-zA-Z0-9\_]/, '_')
		template_name = "#{controller}_#{shortcut}".to_sym
    prefix = controller == :Topic ? '/clubs' : ''
		path          = shortcut == 'home' ? '/' : "#{prefix}/#{raw_shortcut}/"
    txt      ||= shortcut.to_s.capitalize
    if self.template_name.to_s === template_name.to_s
      text(capture {
        li.selected { span "< #{txt} >" }
      })
    else
      text(capture {
        li {
          a txt, :href=>"#{path}"
        }
      })
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

  def the_app
    @the_app = Ignore_Everything.new
  end
  alias_method :app_vars, :the_app

  def mustache mus, &blok
    if block_given?
      text "\n{{\##{mus}}}\n\n"
      yield
      text "\n{{/#{mus}}}\n\n" 
    else
      text "\n{{#{mus}}}\n\n"
    end
  end

  def partial( raw_file_name )
    calling_file = caller[0].split(':').first
    calling_dir  = File.dirname(calling_file)
    file_name = File.expand_path(File.join(calling_dir,raw_file_name)).to_s
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

end # === Markaby::Builder

