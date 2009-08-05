text = %~

~ 


require 'rubygems'
require 'pow'
  Pow("new.mab").create do |file|
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

print "done"
