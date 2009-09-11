

module CoreFuncs

  private

  def development?
    File.exists?('/home/da01')
  end

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

  def app_name
    File.basename( File.expand_path('.') )
  end

  def my_config(key)
    @configs ||= { :life_dir => Pow(File.expand_path('~/MyLife')),
    :BLATO_HELPERS => File.expand_path( '~/' + app_name + '/helpers/blato' ),

    :DESKTOP_DIR => Pow(File.expand_path('~/Desktop')) ,

    :BLATO_LOG => (DESKTOP_DIR / 'blato_log.txt'),

    :BACKUP_DIR => Pow('/media/Patriot/MyLifeBackup') ,

    :MY_EMAIL => 'diego@megauni.com' ,

    :MY_NAME =>  'da01tv'     ,

    :MINIUNI_API_KEY => 'luv.4all.29bal--w0l3mg930--3' ,

    :RAKE_HELPERS    =>   'helpers/rake'
    }
    @configs[:MY_PREFS] ||= ( @configs[:LIFE_DIR] / 'MyPrefs')
    return @configs[key] if @configs.has_key?(key)
    raise ArgumentError, "Unknown config: #{key.inspect}"
  end

  def write_file_or_raise(file, content)
    old_file = file.is_a?(Pow::File) ? file : Pow(file)
    raise ArgumentError, "#{file} already exists." if old_file.exists?
    old_file.create { |f| f.puts content }
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

