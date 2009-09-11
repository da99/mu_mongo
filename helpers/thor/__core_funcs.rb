

module CoreFuncs

  private

  def shout msg, color=:red
    say msg, :red
  end

  def whisper msg
    say msg, :white
  end

  def please_wait(msg)
    say msg, :yellow 
  end

  def primary_app
    'megauni'
  end

  def capture_all(*args)
    args << :single
    shell_capture *args
  end

  def shell_capture(cmd = 'ls', *opts)

    strs = opts.select { |s| s.respond_to?(:strip) }
    args = opts - strs
    
    if !strs.empty?
      cmd = cmd % strs.map { |s| s.inspect }
    end 
    
    valid_args = [:single]
    invalid_args = args - valid_args
    raise "Invalid args: #{invalid_args.inspect}" if !invalid_args.empty?
    results = Open3.popen3(cmd) do |stdin, stdout, stderr|
      [ stdout.read, stderr.read ]
    end 
    
    return results.join("\n").strip if args.include?(:single)

    output, errors = results
    if !output.nil?
      output = output.strip
    end

    if !errors.nil?
      errors = errors.strip
    end

    [ output, errors ]
  end

end # === module CoreFuncs
