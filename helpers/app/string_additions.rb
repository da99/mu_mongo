class String

  def directory_name
    return nil if self.strip == ''
    return self if File.directory?(self)
    ex_dir = File.expand_path(self)
    return ex_dir if File.directory?(ex_dir)
    nil
  end

  def file_name
    return nil if self.strip == ''
    return self if File.file?(self)
    ex_file = File.expand_path(self)
    return ex_file if File.file?(ex_file)
    nil
  end

  def file_system_name
    file_name || directory_name
  end

  def directory?
    directory_name
  end

  def file?
    file_name
  end

  def up_directory *args

    return nil if empty?
    
    dirname = File.dir_name(self)
    
    s = if directory?
      s

    # Compensate for special environment like IRB
    # where __FILE__ might be '(irb)'.
    elsif File.directory?(dirname) 
      dirname

    else
      nil

    end

    return nil if !s

    File.expand_path(File.join(s, '..', *args))
  end

  def down_directory *args
    raise ArgumentError, "Unable to continue w/o arguments: #{args.inspect}" if args.empty?
    raise ArgumentError, "This method is invalid since String is empty." if empty?

    dirname = File.dir_name(self)

    # Handle special case:
    #   __FILE__ == '(irb)'
    d = if directory?
      self 
    elsif File.directory?(dirname)
      dirname 
    else
      nil
    end

    return nil if !d 

    exp = File.expand_path(File.join(d, *args))
  end

  def camelize(first_letter_in_uppercase = :upper)
    s = gsub(/\/(.?)/){|x| "::#{x[-1..-1].upcase unless x == '/'}"}.gsub(/(^|_)(.)/){|x| x[-1..-1].upcase}
    s[0...1] = s[0...1].downcase unless first_letter_in_uppercase == :upper
    s
  end

  def camel_flat
    s = split('_').map(&:capitalize).join('_')
  end

end # === String


