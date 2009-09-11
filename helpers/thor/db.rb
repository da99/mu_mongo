

class Db < Thor

	desc :migrate_up,  "Migrate to latest version." 
  def migrate_up
		whisper "Migrating Up..."
		migrate_it
	end # === 
  
	desc :migrate_down,  "Migrate to version 0. (Erase the database.)" 
  def migrate_down
    whisper "Migrating down... (erasing everyting)..."
		migrate_it(0)
	end # === 
	
	
	desc :reset!, "Migrate to version 0, then migrate up to latest version."
  def reset!
	  invoke :migrate_down
	  invoke :migrate_up
	end # ===
	
	
  desc :to_version, 'Migrate to a specific version.'
  def to_version
    # Use Integer in order to fail if answer 
    # contains non-numeric characters.
    target_v = Integer( ask('Specify version:') ) 
		migrate_it(target_v)
  end	

  private  # =================================================================
 
  def db_connect!
    ENV['RACK_ENV'] ||= 'development'
    return nil if defined? DB
    require Pow('~/.' + app_name)
    require 'sequel/extensions/migration' 
  end
  
  def db_version_as_string
    "Database version: #{Sequel::Migrator.get_current_migration_version(DB)}"
  end
  
  def migrate_it(ver = nil)
    db_connect!
    
    cmd = "sequel #{DB.uri} -m migrations "
    cmd += " -M #{Integer(ver)} " if ver
    
    shout cmd, :yellow
	  results = capture_all( cmd )
		if results.to_s.empty?
		  whisper "Done. #{db_version_as_string}"
		else
		  shout results
      exit
		end	  
  end
  
 
end # === class Db

