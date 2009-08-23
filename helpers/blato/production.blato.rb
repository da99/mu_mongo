class  Production 
  include Blato
  
  def db_connect!
    require Pow("helpers/db_conn")
    require 'sequel/extensions/migration' 
  end
  
  desc :migrate_up, "Migrate to latest DB version."
  def __migrate_up
  
	  puts "Migrating..."
	  
    db_connect!
	  Sequel::Migrator.apply( DB, Pow('migrations') )
	  puts "Done."	
	  
  end
  
 
    
end # === namespace


