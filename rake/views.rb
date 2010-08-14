namespace :views do

  desc 'Generates mustache and css files from mab and sass files.'
  task :compile do
    require 'middleware/Mab_In_Disguise'
    require 'middleware/Xml_In_Disguise'
    require 'middleware/Render_Css'
    Mab_In_Disguise.compile_all
    Xml_In_Disguise.compile_all
    Render_Css.compile_all
    sh('rm -v -r .sass-cache')
  end

  desc 'Create a view file.
    lang=    [en-us]
    model=   [nil]
    control= 
    name= 
  '
  task :create do
    
    lang      = ENV['lang'] || 'en-us'
    control   = assert_not_empty( ENV['control'] )
    name      = assert_not_empty( ENV['name'] )
    filename  = "#{control}_#{name}"
    model     = ENV['model']
    control   = ENV['control']
    model_piece   = control ? "# MODEL   controls/#{model}.rb": ''
    control_piece = model   ? "# CONTROL models/#{model}.rb": ''
    
    assert_match( /\A[a-zA-Z\-\_0-9]+\Z/, filename )

    home    = "~/megauni"
    ldir      = ("~/megauni/templates/#{lang}")
    dir       = File.join( ldir, 'mab' )
    mab       = File.join( ldir, 'mab',   filename + '.rb'   )
    sass      = File.join( ldir, 'sass',  filename + '.sass' )
    view      = File.join( home, 'views', filename + '.rb'   )
    piece_txt = [control_piece, model_piece].compact.join("\n")
    created   = []
    already   = []

    templates = {}
    templates[mab] = %~
# VIEW #{view}
# SASS #{sass}
# NAME #{filename}
#{piece_txt}

div.content! { 
  

  
} # === div.content!

partial('__nav_bar')

~.lstrip

      templates[view] = %~
# MAB   #{mab}
# SASS  #{sass}
# NAME  #{name}
#{piece_txt}

class #{name} < Base_View

  def title 
    '...'
  end
  
end # === #{name} ~.lstrip

      if sass
        templates[sass] = %~
// MAB  #{mab}
// VIEW #{view}
// NAME #{name}
// #{control_piece}
// #{model_piece}

@import layout.sass


~.lstrip
      end

      templates.each do |file, content|
        full_path = File.expand_path(file)
        if File.exists?(full_path)
          puts_white 'Already existed:'
        else
          # Create file.
          File.open( File.expand_path(full_path), 'w') do |file_io|
            file_io.puts content
          end
          puts_white 'Created:'
        end
        
        puts_white file
        
      end

  end # === describe

end # === Views

