
require 'sass'
require 'compass'
require 'ninesixty'

class Render_Css

  def self.compile_all
    new_files = {}
    Dir.glob('templates/*/sass/*.sass').each do |sass_file|
      
      sass_dir    = File.dirname(sass_file)
      css_file    = File.join( 'public', sass_file.gsub('.sass', '.css').sub('templates', 'stylesheets').sub('sass/', '') )
      css_content = Sass::Engine.new(
        File.read(sass_file), 
        :load_paths => [ sass_dir ] + Compass.sass_engine_options[:load_paths] 
      ).render

      puts "Writing: #{css_file}"
      File.open(File.expand_path(css_file), 'w' ) do |f|
        f.write css_content
      end
    end

    new_files
    
  end

  def self.compile file_name = nil
    
    vals = {} 
    
    Dir.glob(file_name || 'templates/*/sass/*.sass').each do |sass_file|
      
      sass_dir    = File.dirname(sass_file)
      css_file    = File.join( 'public', sass_file.gsub('.sass', '.css').sub('templates', 'stylesheets').sub('sass/', '') )
      css_content = Sass::Engine.new(
        File.read(sass_file), 
        :load_paths => [ sass_dir ] + Compass.sass_engine_options[:load_paths] 
      ).render

      vals[sass_file] = [css_file, css_content]
      
    end

    file_name ?
      vals[file_name].last :
      vals
  end

  def self.delete_css
    Dir.glob('public/styles/*/*.css').each { |file|
      puts file
    }
  end

	def initialize new_app
		@app = new_app
		langs = The_App::Options::LANGUAGES.join('|')
		@css_regexp = %r!/stylesheets/(#{langs})/([a-zA-Z0-9\_]+)\.css!
	end


	def call new_env
		
		if not (new_env['PATH_INFO'] =~ @css_regexp)
			return( @app.call(new_env) ) 
		end

    lang, file_name = $1, $2
    sass_file_name  = file_name.sub('.css', '') + '.sass'
    css_content     = self.class.compile("templates/#{lang}/sass/#{sass_file_name}")
		[200, {'Content-Type' => 'text/css'}, css_content ]
		
	end

end # === Render_Css






    # output = `compass --dry-run --trace -r ninesixty -f 960 --sass-dir templates/English/sass --css-dir public/styles/English -s compressed 2>&1`
    # puts output
    # puts $?.exitstatus.to_s
    #   clean_results   = results.split("\n").reject { |line| 
    #     line =~ /^unchanged\ / ||
    #       line.strip =~ /^(compile|exists|create)/
    #   }.join("\n")

    #   raise( clean_results ) if results['WARNING:'] || results['Error']
