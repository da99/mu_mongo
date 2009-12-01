class String

  def expand_path
    File.expand_path self
  end

  def directory_name
    return nil if self.strip.empty?

    [ self, 
      File.expand_path(self),
      File.dirname(File.expand_path(self))
    ].detect { |d_path|
      File.directory? d_path
    }
  end

  def file_name
    return nil if self.strip.empty?
    
    [ self,
      File.expand_path(self)
    ].detect { |f_path|
      File.file? f_path
    }
  end
  
  def file_read
    path = file_name
    return nil if !path
    File.read(path)
  end

  def file_system_name
    file_name || directory_name
  end

  def directory?
    return false if self.strip.empty?
    !![  
      self, 
      File.expand_path(self)
    ].detect { |d_path| 
      File.directory? d_path 
    }
  end

  def file?
    return false if self.strip.empty?
    !![
      self,
      File.expand_path(self)
    ].detect { |f_path|
      File.file? f_path
    }
  end

  def up_directory *args
    
    return nil if self.strip.empty?
    
    dirname = directory_name
    return nil if !dirname

    File.expand_path(File.join(dirname, '..', *args))
  end

  def down_directory *args
    raise ArgumentError, "Unable to continue w/o arguments: #{args.inspect}" if args.empty?
    raise ArgumentError, "This method is invalid since String is empty." if self.strip.empty?

    dirname = directory_name
    return nil if !dirname 

    File.expand_path(File.join(dirname, *args))
  end

  def camelize(first_letter_in_uppercase = :upper)
    s = gsub(/\/(.?)/){|x| "::#{x[-1..-1].upcase unless x == '/'}"}.gsub(/(^|_)(.)/){|x| x[-1..-1].upcase}
    s[0...1] = s[0...1].downcase unless first_letter_in_uppercase == :upper
    s
  end

  def camel_flat
    s = split('_').map(&:capitalize).join('_')
  end

  def ruby_files_wo_rb
    ruby_files false
  end

  def ruby_files w_extension = true
    
    dirname = directory_name
    return [] if !dirname
    
    Dir.entries(dirname).
      reject { |e| e =~ /^\.+$/ }.
      map { |f| 
        path = File.expand_path(File.join(dirname,f))
        if w_extension
          path
        else
          path.sub(/\.rb$/i, '') 
        end
      }
    
  end
  
  def each_file &blok
    return nil if !directory?
    raise ArgumentError, "Block is needed." unless block_given?
    dir = directory_name
    Dir.entries(dir).each { |file_name|
      blok.call File.expand_path(File.join(dir, file_name))
    }
  end
  
end # === String


