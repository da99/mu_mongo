
class Mab
  include Blato


  bla :to_html, {}, "Turn HTML files into MAB files." do
    file_name = ask('Type relative path to file:')
    file = Pow(file_name)
    shout "File not found: #{file.to_s}" if !file.file?
    
    new_file = Pow(file.to_s.gsub(/\.html?$/, '.rb'))
    shout "MAB file already exists: #{new_file}" if new_file.exists?
    
    new_file.create do |file|
      file.puts text.
              gsub( /\<[br]{2,}\ {0,}\/?\>/i, 'br').  # Turn BR tags into single 'br'
              gsub( /\<([a-z1-9]{1,})([^\>]{0,})\/\>/i, '\1(\2 ) ' ). # Turn self-closing elements into regular input elements
              gsub(/\<\/[a-z1-9]{1,}\>/i, "}").
              gsub( /\<([a-z1-9]{1,})([^\>]{0,})\>/i, '\1(\2 ) { ' ).
              gsub( /\ ([a-z0-9\.\:\-\;\&]{1,})\}/i, ' "\1" }').
              gsub( /\(\ {1,}([a-z]{1,})\=([\'\"][a-z])/ , '( :\1=>\2' ).
              gsub( /([\'\"\)\,])\ {1,}([a-z]{1,})\=\'([^\']{1,})\'/i, '\1, :\2=>\'\3\' ').
              gsub( /([\'\"\)\,])\ {1,}([a-z]{1,})\=\'([^\']{1,})\'/i, '\1, :\2=>\'\3\' ').
              gsub( /([a-z1-9]{1,})\ {0,}\(\ {1,}\:class=>\'([a-z\ \_]{1,})\'[\ \,]/i, '\1.\2( ' ).
              gsub( /\.([a-z\_\-\ ]{1,})\(/ ) { |s| 
                s.strip.gsub(/\ {1,}/, '.')
              }.
              gsub( /([^\.])\ {0,}\(\ {0,}\:id\=\>[\'\"]([a-z0-9\_]{2,})[\'\"]\ {0,}\)/, '\1.\2! ')
    end
    
    shout "Created MAB file: #{new_file}.", :white
    
  end

end # === class
