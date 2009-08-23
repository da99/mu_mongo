

class Sass
  include Blato
  
  # desc :compile, 
  bla  :compile, "Turn all SASS files to CSS."  do
    return nil if  !Pow('views/skins/jinx/sass').exists?
    compile_results = capture("compass -r ninesixty -f 960 --sass-dir views/skins/jinx/sass --css-dir public/skins/jinx/css -s compressed")
    clean_results   = compile_results.split("\n").reject { |line| 
                                                            line =~ /^unchanged\ / ||
                                                            line.strip =~ /^(compile|exists|create)/
                                                         }.join("\n")
    
    raise( clean_results ) if compile_results['WARNING:'] || compile_results['Error']
    
    whisper "Compiled SASS to CSS"
    
  end # === def
  
  bla :delete, "Delete compiled CSS files.." do
    return nil if !Pow('views/skins/jinx/sass').exists?
    Pow('views/skins/jinx/sass').each { |f| 
      if f.file? && f.to_s =~ /\.sass$/ 
        css_file = Pow( 'public/skins/jinx/css', File.basename(f.to_s).sub( /\.sass$/, '') + '.css' )
        css_file.delete if css_file.exists? 
      end
    }
    whisper "Deleted compiled CSS files."
  end
  
end # === class


