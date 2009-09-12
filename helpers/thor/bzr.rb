class Bzr < Thor
  include Thor::Sandbox::CoreFuncs

  BZR_DIR= ( LIFE_DIR / '.bzr' )
  BZR_LOG =  Pow(File.expand_path('~/.bzr.log'))
  
  desc :quiet_my_life_dev_check, "Just like :my_life_dev_check, but stores all output in ~/.bzr.log"
  def quiet_my_life_dev_check
    status = capture_all( 'thor bzr:my_life_dev_check' )
    orig_log = BZR_LOG.read
    BZR_LOG.create {|f|
      f.puts orig_log + status
    }
  end

  desc :my_life_dev_check, "Commits, if any, changes as a dev. check., then copies to BACKUP_DIR"
  def my_life_dev_check
    status = "cd %s && " % (LIFE_DIR).to_s
    Dir.chdir( LIFE_DIR.to_s )

    # Check if errors occurred last time.
    if BZR_LOG.exists?
      bzr_log_contents = BZR_LOG.read
      if bzr_log_contents[/return code [1-9]/]
        append_to_my_error_log  bzr_log_contents
        shout "Bzr errors. Check desktop for error list."
      end

      # We must delete the BZR log to prevent same errors from bein
      # written again to Desktop error log.
      BZR_LOG.delete 
    end

    # Find all files with unusual characters in filename.
    pattern = /[^a-z0-9\/\,\ \.\_\-]/i
    files = capture_all("find %s -iname \"*.desktop\"", LIFE_DIR ).split("\n")
    files.each { |f|
      if f =~ pattern
        new_file_path = File.join( File.dirname(f), File.basename( f ).gsub( pattern , '-') )
        whisper capture_all("mv %s %s", f, new_file_path )
      end
    }

    return( whisper 'Nothing to commit.' ) if commits_pending?
    
    whisper capture_all( 'bzr commit -m %s ', "Development checkpoint: #{Time.now.to_s}" )
    
    if !(BACKUP_DIR).exists?
      msg = 'Backup dir. does not exist: ' + BACKUP_DIR.to_s
      append_to_my_error_log msg
      return( shout( msg ) ) 
    end

    whisper "Copying changes into backup dir: #{BACKUP_DIR}..."

    # Copy recursive: -R
    # changed files only: -u
    copy_status = capture_all("cp -Ru %s %s" , BZR_DIR, BACKUP_DIR )

    if copy_status.empty?
      whisper "Done"
    else
      append_to_my_error_log copy_status
      shout "ERROR: #{copy_status}"
    end

    copy_status
  end

  private # ==============================================================

  def commits_pending?
    capture_all('bzr add ')
    capture_all('bzr status').to_s.strip[ /(added|removed|modified)\:/ ]
  end


end

