
def sass 
  Rake::Task['sass:compile'].invoke
  yield
  Rake::Task['sass:delete'].invoke
end

namespace 'sass' do
  
  
  desc "Turn all SASS files to CSS."
	
	task :compile do
    
		if File.directory?('views/skins/jinx/sass') # .directory?
      puts "Compiling SASS to CSS...\n"
      sh(
          "compass -r ninesixty -f 960 --sass-dir views/skins/jinx/sass --css-dir public/skins/jinx/css -s compressed"
      )
      clean_results   = results.split("\n").reject { |line| 
        line =~ /^unchanged\ / ||
          line.strip =~ /^(compile|exists|create)/
      }.join("\n")

      raise( clean_results ) if results['WARNING:'] || results['Error']
      Rake::Task[:delete_sass_cache].invoke
    end
    
  end # === def
  
  desc "Delete compiled CSS files.."
  task :delete do
		
		puts "Deleting compiled CSS files.\n"
      unless File.directory?('views/skins/jinx/sass') # .directory?
        nil
      else 

        public_dir = 'public/skins/jinx/css'.directory.path

        'views/skins/jinx/sass'.directory.each_file { |f| 
          if f.has_extension?(:sass)
            css_file = File.join(public_dir, f.file.name.replace_extension( :css ) )
            File.delete(css_file) if css_file.file? 
          end
        }

        Rake::Task[:delete_sass_cache].invoke

        puts_white "Deleted compiled CSS files."
      end
  end
  
  desc "Delete .sass-cache dir."
  task :delete_sass_cache do  
		if '.sass-cache'.directory?
			sh('rm -r .sass-cache')
		end
  end
  
end # === class
