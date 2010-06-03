

namespace 'sass' do
  
  desc "Turn all SASS files to CSS."
	task :compile do
		puts "Compiling SASS to CSS..."
		require 'middleware/Render_Css'
		Render_Css.compile.each { |sass_file, (css_file, content)|
			File.open(css_file, 'w') do |file|
				file.puts content
			end
		}
  end # === def

	task :cleanup do
		puts 'Deleting CSS files.'
		Dir.glob("public/styles/*/*.css").each { |file| 
			File.delete file
		}
		sh "rm -r .sass-cache" if File.directory?('.sass-cache')
	end

  desc "Convert from Sass2 because Sass syntax has been updated."
  task :convert_all do
    require 'middleware/Render_Css'
    Render_Css.sass_files.each { |file| 
      puts_white `sass-convert --in-place --from sass2 #{file}`
    }
  end
  
end # === class
