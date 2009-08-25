class Bzr
  include Blato

  BZR_DIR = ( LIFE_DIR / '.bzr' )
  def commits_pending?
    capture('bzr add ')
    !capture('bzr status').to_s.strip.empty? 
  end
  
  bla :quiet_my_life_dev_check, {}, "Just like :my_life_dev_check, but stores all output in ~/.bzr.log" do
    bzr_log = Pow(File.expand_path('~/.bzr.log'))
    status = capture_task( :my_life_dev_check )
    orig_log = bzr_log.read
    bzr_log.create {|f|
      f.puts orig_log + status
    }
  end
  
  bla :my_life_dev_check, {}, "Commits, if any, changes as a dev. check., then copies to BACKUP_DIR" do
    status = "cd %s && " % LIFE_DIR.to_s
    Dir.chdir( LIFE_DIR.to_s )
    
    # Check if errors occurred last time.
    bzr_log =  Pow(File.expand_path('~/.bzr.log')) 
    if bzr_log.exists?
      bzr_log_contents = bzr_log.read
      if bzr_log_contents[/return code [1-9]/]
        Pow(File.expand_path('~/Desktop/errors_in_my_life.txt')).create { |f|
          f.puts bzr_log_contents
        }
        Blato.log_error("Bzr errors", "Check desktop for error list.")
      end
      
      bzr_log.delete
    end
    
    # Find all files with unusual characters in filename.
    pattern = /[^a-z0-9\/\,\ \.\_\-]/i
    files = capture("find %s -iname \"*.desktop\"" % LIFE_DIR).split("\n")
    files.each { |f|
      if f =~ pattern
        new_file_path = File.join( File.dirname(f), File.basename( f ).gsub( pattern , '-') )
        Blato.append_file( BLATO_LOG, "Changing file path: #{f}")
        shout capture("mv %s %s" % [ f.inspect, new_file_path.inspect] ), :white
      end
    }
    
    if commits_pending?
      shout( capture( 'bzr commit -m %s ', "Development checkpoint: #{Time.now.to_s}" ) , :white )
      return(shout('Backup dir. does not exist.')) if !BACKUP_DIR.exists?
      
      # Delete old backups.
      
      shout "Creating new backup...", :white
      
      # Copy recursive -R, 
      # changed files only -u
      copy_status = capture("cp -Ru %s %s" % [BZR_DIR.to_s, BACKUP_DIR.to_s]) 
      
      if copy_status.to_s.strip.empty?
        shout "Backed up to #{BACKUP_DIR}", :white
      else
        shout "ERROR: #{copy_status}"
      end
    else
      shout( 'Nothing to commit.', :white)
    end
  end
  

end
