require 'rubygems'
require 'pow'


dir = Pow("/media/disk/Code Geass")

dir.sort.each { |obj|
  if obj.file?
    old_name = obj.to_s
    new_name = obj.to_s.sub("/Code Geass/Code Geass ", "/Code Geass/")
    if old_name != new_name
      # system( "mv \"#{old_name}\" \"#{new_name}\" \n" )  
    end
    system("touch \"#{new_name}\"\n")
  end
  
}

