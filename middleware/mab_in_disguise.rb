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
  
  def nav_bar_li controller, raw_shortcut, txt = nil
		shortcut      = raw_shortcut.gsub(/[^a-zA-Z0-9\_]/, '_')
		template_name = "#{controller}_#{shortcut}".to_sym
		path          = shortcut == 'home' ? '/' : "/#{raw_shortcut}/"
    txt      ||= shortcut.to_s.capitalize
    if self.template_name === template_name
      text(capture {
        li.selected { span "< #{txt} " }
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

  def save_to(name,  &new_proc)
    text "\nNot done: save_to #{name.inspect}\n"
    return
    instance_variable_set( :"@#{name}" , capture(&new_proc) )       
  end # === save_to

  def checkbox selected, attrs
    defaults = { :type=>'checkbox' }
    if selected
      defaults[:checked] = 'checked'
    end
    input attrs.update(defaults)     
  end

	def partial file_name
		caller_file = File.expand_path(caller[0].split(':').first)
		caller_dir  = File.dirname(File.expand_path(caller_file))
		partial_file = File.join(caller_dir, file_name)
		raise "Not a file: #{partial_file}" if not File.file?(partial_file)
		partial_content = File.read(partial_file)
		eval(partial_content, nil, partial_file, 1)
	end

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

class Mab_In_Disguise
  
  def initialize new_app
		@m_times = {}
    @app = new_app
  end
  
  def call new_env

    if ENV['RACK_ENV'] != 'development'
      raise("Can't be used in this environment: #{ENV['RACK_ENV']}") 
    end

    template_dirs.each { |dir|
      
      mab_dir        = File.join(dir, 'mab')
      mus_dir        = File.join(dir, 'mustache')
      layout_content = File.read(layout_file(mab_dir))
      
      # Delete all Mustache files.
      Dir.glob( File.join(mus_dir, '*.html') ).each do |html_file|
        File.delete(html_file)
      end

    }
    
    @app.call(new_env)
  end
  
  def template_dirs
    Dir.glob('templates/*').map { |dir|
      if File.directory?(dir)
        File.expand_path(dir) 
      else
        nil
      end
    }.compact
  end

  def template_files dir
    Dir.glob(File.join(dir, '*.rb')).map { |file_name|
      if File.basename(file_name) != 'layout.rb'
        File.expand_path(file_name) 
      end
    }.compact
  end

  def layout_file dir
    File.join(dir, 'layout.rb')
  end

  def render_mab( file_name_or_opts = nil )

    # =================================================================
    # Determine if a layout is required.
    if !use_layout 
      return Markaby::Builder.new(ivs).capture { 
        eval( the_content, nil, the_file_path, 1 ) 
      }
    else
      #  =================================================================
      # Grab & Render the Markaby content for current action.
      dev_log_it "Rendering Markaby: #{template_file_name}"
      dev_log_it "... with layout: #{layout_file_name}"

      the_content = layout_file_content
      the_file_path = layout_file_path

      Markaby::Builder.new( ivs ) {
        eval( the_content ,  nil,  the_file_path , 1  )
      }.to_s                  


    end

  end # === render_mab   
  
  def self.mab_to_mustache lang, template_name
    file_basename = template_name.to_s
    
    mab_dir       = File.join('templates', lang, 'mab')
    mab_file      = File.join(mab_dir, file_basename.to_s + '.rb')
    layout_file   = File.join(mab_dir, 'layout.rb')
    
    mus_dir       = File.join('templates', lang, 'mustache')
    mus_file      = File.join(mus_dir, file_basename.to_s + '.html')
      
    return nil if file_basename[/Heart|News|Topic|textile|\.xml\./]
    
    is_partial    = file_basename[/^__/]

    content = if is_partial
      File.read(mab_file)
    else
      File.read(layout_file).sub("{{content_file}}", file_basename)
    end

    compiled = Markaby::Builder.new(:template_name=>template_name) { 
      eval(content, nil, is_partial ? mab_file : layout_file, 1)
    }

    # File.open(mus_file, 'w') { |f_io| 
    #   f_io.write compiled 
    # }

    compiled
  end

end # === Mab_In_Disguise
