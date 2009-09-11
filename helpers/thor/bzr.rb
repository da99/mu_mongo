class Bzr < Thor
  include Thor::Sandbox::CoreFuncs

  BZR_LOG =  Pow(File.expand_path('~/.bzr.log'))
  desc :quiet_my_life_dev_check, "Just like :my_life_dev_check, but stores all output in ~/.bzr.log"

  def quiet_my_life_dev_check
    bzr_log = BZR_LOG
    status = capture_all( 'thor bzr:my_life_dev_check' )
    orig_log = bzr_log.read
    bzr_log.create {|f|
      f.puts orig_log + status
    }
  end

  desc :my_life_dev_check, "Commits, if any, changes as a dev. check., then copies to BACKUP_DIR"
  def my_life_dev_check
    status = "cd %s && " % (LIFE_DIR).to_s
    Dir.chdir( (LIFE_DIR).to_s )

    # Check if errors occurred last time.
    bzr_log =  BZR_LOG
    if bzr_log.exists?
      bzr_log_contents = bzr_log.read
      if bzr_log_contents[/return code [1-9]/]
        Pow(File.expand_path('~/Desktop/errors_in_my_life.txt')).create { |f|
          f.puts bzr_log_contents
        }
        shout "Bzr errors", "Check desktop for error list."
      end

      bzr_log.delete
    end

    # Find all files with unusual characters in filename.
    pattern = /[^a-z0-9\/\,\ \.\_\-]/i
    files = capture_all("find %s -iname \"*.desktop\"" % (LIFE_DIR) ).split("\n")
    files.each { |f|
      if f =~ pattern
        new_file_path = File.join( File.dirname(f), File.basename( f ).gsub( pattern , '-') )
        whisper capture_all("mv %s %s", f, new_file_path )
      end
    }

    if commits_pending?
      whisper capture_all( 'bzr commit -m %s ', "Development checkpoint: #{Time.now.to_s}" )
      return(shout('Backup dir. does not exist.')) if !(BACKUP_DIR).exists?

      # Delete old backups.

      whisper "Creating new backup..."

      # Copy recursive: -R
      # changed files only: -u
      copy_status = capture_all("cp -Ru %s %s" % [BZR_DIR().to_s, (BACKUP_DIR).to_s])

      if copy_status.to_s.strip.empty?
        whisper "Backed up to #{(BACKUP_DIR)}"
      else
        shout "ERROR: #{copy_status}"
      end
    else
      whisper 'Nothing to commit.' 
    end
  end

  private

  def commits_pending?
    capture_all('bzr add ')
    capture_all('bzr status').to_s.strip[ /(added|removed|modified)\:/ ]
  end

  def BZR_DIR()
    ( (MY_PREFS) / '.bzr' )
  end

end

