
require 'sass'
require 'compass'
require 'ninesixty'

class Render_Css


	def initialize new_app
		@app = new_app
		langs = The_App::Options::LANGUAGES.join('|')
		@css_regexp = %r!/stylesheets/#{langs}/[a-zA-Z0-9\_]+\.css!
	end


	def call new_env
		
		#require 'rubygems'; require 'ruby-debug'; debugger
		
		
		if not (new_env['PATH_INFO'] =~ @css_regexp)
			return( @app.call(new_env) ) 
		end

		lang, file_name = new_env['PATH_INFO'].split('/')[-2,2]

		if not The_App::Options::LANGUAGES.include?(lang)
			return @app.call(new_env)
		end

		sass_dir       = File.expand_path(File.join('templates', lang, 'sass'))
		sass_file_name = file_name.sub('.css', '') + '.sass'
		sass_file      = File.join(sass_dir, sass_file_name)
		if not File.file?(sass_file)
			return @app.call(new_env)
		end
		
    css_content = ::Sass::Engine.new( 
        File.read(sass_file), 
        :load_paths=> [ sass_dir ] + Compass.sass_engine_options[:load_paths] 
    ).render 

		[200, {'Content-Type' => 'text/css'}, css_content ]
		
	end


end # === Render_Css
