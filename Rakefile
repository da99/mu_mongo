
# require 'rubygems'
# require 'sequel'  

namespace :production do

  desc "Migrate to latest DB version."
  task :migrate_up  do
    
	  puts "Migrating..."
	  cmd = "sequel #{ENV['DATABASE_URL']} -m migrations "
	  puts `#{cmd} 2>&1`
	  
  end

end # === namespace


__END__
        'ruby-pg' => [ "Make sure Postgresql is installed.\n",
                       "Then install: \nsudo apt-get install postgresql-server-dev-8.x.\n",
                       "Replace 'x' with the latest Postgresql version you are using.\n",
                       "If it still does not work: try using the 'postgres' gem instead.\n",
                       "More info: http://rubyforge.org/projects/ruby-pg" ].join("\n"),
        'sinatra-sinatra' => nil,   
        'nakajima-rack-flash' => nil,                      
        'ruby2ruby' => nil,
        'ParseTree' => nil,        
        'sequel' => nil,
        'pow' => nil,        
        'sanitize' => nil,
        'html5' => nil, # For use with HTML5_sanitize lib. 
        'htmlentities' => nil, 
        
        'thin' => nil,

        'haml' => [ "Necessary for SASS processing.",
                    "Install using git because the COMPASS gem relies on",
                    "the latest HAML/SASS gem through nex3's repository.",
                    "git clone git://github.com/nex3/haml.git",
                    "cd haml",
                    "sudo rake install"].join("\n"),
        


        


