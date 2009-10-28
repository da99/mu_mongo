
namespace :production do

  desc "Migrate to latest DB version."
  task :migrate_up  do
    
	  puts "Migrating..."
	  cmd = "sequel #{ENV['DATABASE_URL']} -m migrations "
	  results =  `#{cmd} 2>&1`
	  if results.to_s.strip.empty?
  	  puts 'Done. No errors.'
  	else
  	  puts "Errors: "
  	end
  	
  	puts results
	  
  end

end # === namespace

        


        


