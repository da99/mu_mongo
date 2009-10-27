#!/home/da01/rubyee/bin/ruby
$KCODE = 'u' 

require File.expand_path('~/megauni/helpers/kernel')
require 'open3'
require 'rush'
require File.expand_path('~/megauni/helpers/string_inflections')

module CoreFuncs
  PRIMARY_APP     = 'megauni'
  APP_NAME        = File.basename(File.expand_path('.'))
  LIFE_DIR        = Pow(File.expand_path('~/MyLife'))
  MY_PREFS        = (LIFE_DIR / "prefs")
  DESKTOP_DIR     = Pow('~/Desktop')
  BLATO_LOG       = (DESKTOP_DIR / 'blato_log.txt')
  BACKUP_DIR      = Pow('~/Dropbox/BZR_DIR')
  BZR_DIR         = ( LIFE_DIR / '.bzr' )
  MY_ERROR_LOG    = Pow('~/Desktop/errors_from_thor.txt')
  MY_EMAIL        = 'diego@miniuni.com'
  MY_NAME         = 'da01tv'
  MINIUNI_API_KEY = 'luv.4all.29bal--w0l3mg930--3'
  RAKE_HELPERS    = 'helpers/rake'
  
  private

  def development?
    File.exists?('/home/da01')
  end

  def make_symlink_or_raise(target, new_path)
    raise ArgumentError, "Target doesn not exists: #{target}" if !File.exists?(target.to_s)
    raise ArgumentError, "New path already exists: #{new_path}" if File.exists?(new_path.to_s)

    results = capture_all( "ln -s %s %s" , target, new_path)
    raise ArgumentError, results if !results.empty?
    true
  end

  def append_to_my_error_log(content)
    orig_content = ''
    error_log = MY_ERROR_LOG
    if MY_ERROR_LOG.exists?
      if MY_ERROR_LOG.file?
        orig_content = MY_ERROR_LOG.read
      else
        orig_content = 'ERROR LOG NEEDS TO BE A FILE: ' + MY_ERROR_LOG.to_s
        error_log = Pow("~/Desktop/new_error_log.#{Time.now.utc.to_i}.txt")
      end
    end
    error_log.create {|f| 
      f.puts content + orig_content
    }
  end

  def shout msg, color=:red
    say msg, :red
  end

  def whisper msg
    say msg, :white
  end

  def please_wait(msg)
    say msg + "\n", :yellow
  end


  def app_name
    File.basename( File.expand_path('.') )
  end

  def my_config(key)
    @configs ||= { 

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
    shell_capture( *args ).join("\n").strip
  end

  def shell_capture(*args)
    stem    = args.shift
    cmd     = stem % ( args.map { |s| s.to_s.inspect } )
    
    results = Open3.popen3( cmd ) { |stdin, stdout, stderr|
      [ stdout.read, stderr.read ].map { |s|
        s.respond_to?(:strip) ?
          s.strip :
          s
      }
    }
  end

end # === module CoreFuncs


Dir['helpers/thor/*.rb'].each do |file|
  file_name = file.sub(/\.rb$/, '')
  if file !~ /core_funcs/
    require Pow( file )
  end
end

