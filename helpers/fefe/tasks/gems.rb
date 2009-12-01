class Gems 
    
    include FeFe
    
    describe :install do
      it "It's the same as :update."
      steps {
        run_task :update
      }
    end

    describe :update  do
      
      it "Installs and updates all gems from manifest (.gems)" 
      
      steps {
        gem_manifest = File.join('~/', PRIMARY_APP, '.gems')
        demand_file_exists gem_manifest

        gems_to_install = gem_manifest.file_read.strip.split("\n")

        dev_gems = File.join('~/', PRIMARY_APP, '.development_gems' )
        gems_to_install = gems_to_install + (dev_gems).file_read.strip.split("\n")

        installed =  shell_out('gem list')
        if gems_to_install.empty?
          puts_white  "No gems to install."
        else
          gems_to_install.each { |g|
            gem_name = g.split.first.strip
            if gem_name[/^[a-z0-9]/i] # Starts w/ alpha-numeric character ???
              if installed["#{gem_name} ("]
                puts_white "Already installed: #{gem_name}"
              else
                puts_white shell_out( "gem install #{gem_name}")
              end
            end
          }
        end    

        puts_white {
          system('gem update') 
        }
      }
    end   
     
end # === namespace :gems
