class  Production 
  include Blato
  

  
  bla :migrate_up, "Migrate to latest DB version." do
  
	  puts "Migrating..."
	  cmd = "sequel #{ENV['DATABASE_URL']} -m migrations "
	  puts( system(cmd) )
	  puts "Done."	
	  
  end
  
 
    
end # === namespace


