

class Db

  include Blato

  def db_connect!
    return nil if defined? DB
    require Pow('~/.' + APP_NAME)
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
	  results = capture( cmd ) # Sequel::Migrator.apply( DB, Pow('migrations'), 0 )
		if results.to_s.empty?
		  shout "Done. #{db_version_as_string}", :white
		else
		  shout results
      exit
		end	  
  end
  
	bla :migrate_up,  "Migrate to latest version." do
		shout "Migrating Up...", :white
		migrate_it
	end # === 
  
	bla :migrate_down,  "Migrate to version 0. (Erase the database.)" do
    shout "Migrating down... (erasing everyting)...", :white
		migrate_it(0)
	end # === 
	
	
	bla :reset!, "Migrate to version 0, then migrate up to latest version." do
	  invoke :migrate_down
	  invoke :migrate_up
	end # ===
	
	
  bla :to_version, 'Migrate to a specific version.' do
    # Use Integer in order to fail if answer 
    # contains non-numeric characters.
    target_v = Integer( HighLine.new.ask('Specify version:') ) 
		migrate_it(target_v)
  end	
	
end # ==== :namespace: db

