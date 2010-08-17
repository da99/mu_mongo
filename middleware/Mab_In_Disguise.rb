
require 'markaby'

# puts "\n"
# puts caller.join("\n")
# puts "\n"

MAB_MODS = %w{ 
  Base 
  Base_Js
  Base_Forms
  Base_Club
  Base_Message
  Base_Member_Life 
}

MAB_MODS.each { |mod|
  require( "templates/en-us/mab/__#{mod}" ) 
}

class Markaby::Builder
  
  set(:indent, 1)
  MAB_MODS.each { |mod| include eval(mod) }

end # === Markaby::Builder


class Mab_In_Disguise
  
  def self.folder_name str
    File.basename(File.dirname(str))
  end

  def self.save_file mab_file, html_file, content
      invalid_html = folder_name(html_file) != 'mustache'
      raise "Invalid HTML directory: #{html_file}" if invalid_html
      
      invalid_mab = %w{xml mab}.include? folder_name(mab_file)
      raise "Invalid MAB directory: #{mab_file}" if invalid_mab

      puts("Writing: #{html_file}") if The_App.development?
      parser    = Mustache::Parser.new
      generator = Mustache::Generator.new
      File.open(html_file, 'w') do |f|
        f.write generator.compile(parser.compile(content.to_s))
      end
      
      `touch "#{html_file}" && touch #{mab_file}`
  end

  def self.compile_all filename = '*'
    Dir.glob("templates/*/mab/#{filename}.rb").each { |mab_file|
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
      save_file(mab_file, html_file, content)
    }
  end

  def self.compile file_name = nil
    compile_all file_name
    # vals = {}
    # mab_file      = file_name
    # mab_dir       = File.dirname(mab_file)
    # layout_file   = File.join(mab_dir, 'layout.rb')
    # file_basename = File.basename(mab_file)
    # is_partial    = file_basename[/^__/]
    # html_file     = mab_file.sub('mab/', 'mustache/').sub('.rb', '.html')
    # template_name = file_basename.sub('.rb', '').to_sym

    # content       = if is_partial
    #                   Markaby::Builder.new(:template_name=>template_name) { 
    #                     eval( File.read(mab_file), nil, mab_file , 1)
    #                   }
    #                 else
    #                   Markaby::Builder.new(:template_name=>template_name) { 
    #                     eval(
    #                       File.read(layout_file).sub("{{content_file}}", file_basename),
    #                       nil, 
    #                       layout_file, 
    #                       1
    #                   )
    #                   }
    #                 end

    # vals[mab_file] = [html_file, content]

    # if file_name 
    #   if !vals[file_name]
    #     raise ArgumentError, "Template not found: #{file_name}. Available templates: #{vals.keys.join(', ')}"
    #   end
    #   vals[file_name].last
    # else
    #   vals
    # end
  end
  
end # === class Mab_In_Disguise

