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
