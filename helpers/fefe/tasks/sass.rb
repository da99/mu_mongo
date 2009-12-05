

class Sass
  
  include FeFe  
  
  describe :compile do
    it "Turn all SASS files to CSS."
    
    steps {
      return nil if !'views/skins/jinx/sass'.directory?
      puts_white "Compiling SASS to CSS..."
      results = shell_out(
        "compass -r ninesixty -f 960 --sass-dir views/skins/jinx/sass --css-dir public/skins/jinx/css -s compressed"
      )
      clean_results   = results.split("\n").reject { |line| 
        line =~ /^unchanged\ / ||
          line.strip =~ /^(compile|exists|create)/
      }.join("\n")
      
      raise( clean_results ) if results['WARNING:'] || results['Error']
      run_task :delete_sass_cache, {}
      true
    }
  end # === def
  
  describe :delete do
    it "Delete compiled CSS files.."
    
    steps do
      return nil if !'views/skins/jinx/sass'.directory?

      public_dir = 'public/skins/jinx/css'.directory.path

      'views/skins/jinx/sass'.directory.each_file { |f| 
        if f.has_extension?('.sass')
          css_file = File.join(public_dir, f.file.name.replace_extension( '.css' ) )
          File.delete(css_file) if css_file.file? 
        end
      }

      run_task(:delete_sass_cache, {})

      puts_white "Deleted compiled CSS files."
    end
  end
  
  describe :delete_sass_cache do
    it "Delete .sass-cache dir."
    steps {
      if '.sass-cache'.directory?
        shell_out('rm -r .sass-cache')
      end
    }
  end
  
end # === class


