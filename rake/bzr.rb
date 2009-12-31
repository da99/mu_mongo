

class Bzr
  include FeFe

  BZR_LOG              = '~/.bzr.log'
  INVALID_FILE_PATTERN = /[^a-z0-9\/\,\ \.\_\-]/i
  BACKUP_DIR           = '~/Dropbox/BZR_DIR'
  
  describe :backup_life do 
    
    it "Commits, if any, changes as a dev. check., then copies to BACKUP_DIR"
    
    steps do 
      
      orig_wd = Dir.getwd
      
      Dir.chdir( MY_PREFS )

      # Find all files with unusual characters in filename.
      files = shell_out('find %s -iname "*.desktop"', MY_PREFS ).split("\n")
      files.each { |f|
        if f =~ INVALID_FILE_PATTERN
          new_file_path = File.join( File.dirname(f), File.basename( f ).gsub( pattern , '-') )
          puts_white shell_out("mv %s %s", f, new_file_path )
        end
      }

      if !commits_pending?
        puts_white 'Nothing to commit.'
        return false
      end

      puts_white 'Please wait as your life is being backed up...'
      shell_out( 'bzr commit -m %s ', "Development checkpoint: #{Time.now.to_s}" ) { |msg_arr, err_arr|
        
        messages, errors = if err_arr.detect { |m| m[/Committed revision [0-9]{1,}\./] }
          [(msg_arr + err_arr), [] ]
        else
          [msg_arr, err_arr]
        end
        
        messages.each { |m|
          puts_white m
        }
        errors.each { |m|
          puts_red m
        }
        
      }

      if !BACKUP_DIR.directory?
        raise ArgumentError, "Backup dir. does not exist: #{BACKUP_DIR}" 
      end

      puts_white "Done with the backup."
      
      Dir.chdir orig_wd
      
      true
    end
  end

  private # ==============================================================

  def commits_pending?
    shell_out('bzr add ')
    shell_out('bzr status').to_s.strip[ /(added|removed|modified)\:/ ]
  end


end


