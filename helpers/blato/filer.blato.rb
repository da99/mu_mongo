class Filer
    include Blato

    def get_and_validate_ext(q)
        ext = HighLine.new.ask(q).to_s.sub(/^\.{1,}/, '').strip
        raise ArgumentError, "Invalid file extension: #{ext}" if ext.empty?
        ext
    end

    bla :rename_ext, "Rename file extension of files in a directory." do
        hl = HighLine.new
        
        dir = hl.ask("Enter directory: #{Pow()}/").to_s.sub(/^\/{1,}/, '').strip
        raise ArgumentError, "Empty dir name not allowed." if dir.empty?
    
        oDir = Pow(dir)
        raise ArgumentError, "Dir does not exist: #{oDir}" if !oDir.directory?
        
        ext = get_and_validate_ext("Enter extension:")
        new_ext = get_and_validate_ext("Enter new extention:")

        oDir.each { |file|
            ext_reg = /\.#{ext}$/
            if file.file? && file.to_s =~ ext_reg
                old_name = file.to_s
                new_name = file.to_s.sub(/\.#{ext}$/, ".#{new_ext}")
                if Pow(new_name).exists?
                    shout "New file already exists: #{new_name}"
                else
                    shout capture("mv %s %s" % [old_name.inspect, new_name.inspect] ).to_s 
                end 
            else
                shout "Skipping non-file: #{file}", :white if !file.file?
                shout "Skipping non-#{ext}: #{file}", :white if file.to_s !~ ext_reg
            end
        }
        shout "Done.", :white
    end
end
