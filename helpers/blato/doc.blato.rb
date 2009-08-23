class Doc
  include Blato
  
  bla :generate , "Generate documentation." do
      ignore_files = File.read(".gitignore").map { |l| 
                        new_l = l.strip
                        ( new_l = new_l.sub('*','') + '$' ) if new_l =~ /\*/
                        ( new_l = nil ) if new_l =~ /\#/ || new_l.empty?
                        new_l
                     }.compact.join("|").gsub( /^\/|\/$/, '') # take out any beginning/trailing slashes

      ignore_files +=  '|spec_it.rb|spec\/'  # add file 'spec_it.rb' and dir 'spec/'

      system "rdoc -U -x '#{ignore_files}' "
      system "echo 'ignored files/dirs: " + ignore_files.split('|').join("\n") + "' "    
  end # === task
  
end # === namespace :doc
