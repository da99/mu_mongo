require 'markaby'

class Markaby::Builder
  
  set(:indent, 1)
  
  def save_to(name,  &new_proc)
    raise "Not done."
    instance_variable_set( :"@#{name}" , capture(&new_proc) )       
  end # === save_to

  def checkbox selected, attrs
    defaults = { :type=>'checkbox' }
    if selected
      defaults[:checked] = 'checked'
    end
    input attrs.update(defaults)     
  end

  def mustache mus
    text(
       "\n#{mus}\n\n"
    )
  end

  def partial( raw_file_name )
    
    file_name = File.expand_path(raw_file_name).to_s
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
      
      template_files(mab_dir).each { |file_name|
        
        new_file_name = File.join(mus_dir, File.basename(file_name) )
        is_partial    = file_name[/^__/]
        content       = File.read(file_name)

        if not is_partial
          content = layout_content.sub("\n#! content\n", "\n\n#{content}\n\n")
        end

        compiled      = Markaby::Builder.new { eval(content, nil, file_name, 2) }
        
        # puts "Writing to file: #{new_file_name}"
        File.open(new_file_name, 'w') { |f_io| 
          f_io.write compiled 
        }

      }
      
    }
    
    # require 'rubygems'; require 'ruby-debug'; debugger
    
    
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
end # === Mab_In_Disguise
