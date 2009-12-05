class Gems 
    
    include FeFe
    
    GEM_MANIFEST       = File.join('~/', PRIMARY_APP, '.gems').file.expand_path
    GEM_MANIFEST_ARRAY = GEM_MANIFEST.file.read.strip.split("\n")
    GEM_PRODUCTION_PAIR = [GEM_MANIFEST, GEM_MANIFEST_ARRAY]

    GEM_MANIFEST_DEV   = GEM_MANIFEST.sub('.gems', '.development_gems')
    GEM_MANIFEST_DEV_ARRAY = GEM_MANIFEST_DEV.file.read.strip.split("\n")
    GEM_DEVELOPMENT_PAIR = [GEM_MANIFEST_DEV, GEM_MANIFEST_DEV_ARRAY]

    describe :development_install do
      it 'It install a gem for the development environment.'
      steps([:cmd, nil]) do |cmd|
        run_task :install, :cmd => cmd, :env=>'development'
      end
    end

    describe :production_install do
      it 'It install a gem for the production environment.'
      steps([:cmd, nil]) do |cmd|
        run_task :install, :cmd => cmd, :env=>'production'
      end
    end

    describe :install do
      it "Install a gem and update appropriate gem manifest."
      steps([:cmd, nil], [:env, :production]) { |raw_command, env|
        
        demand_array_includes %w{production development}, env
        command = demand_string_not_empty raw_command

        puts_white "Installing: #{command}"
        
        ok = system "gem install --no-ri --no-rdoc --backtrace #{command}"
        
        return false if !ok

        file , arr = eval("GEM_#{env.upcase}_PAIR")

        gem_name = command.strip.split.first
        new_arr = arr.reject { |g| g.strip.split.first.upcase == gem_name.upcase } 
        new_arr << command
        File.open(file, 'w') { |f|
          f.write new_arr.join("\n")
        }

        ok
      }
    end

    describe :development_uninstall do
      it 'Uninstalls a gem in the .development_gems file.'
      steps([:cmd, nil]) do |cmd|
        run_task :uninstall, :cmd=>cmd, :env=>'development'
      end
    end
    
    describe :production_uninstall do
      it 'Uninstalls a gem in the .production_gems file.'
      steps([:cmd, nil]) do |cmd|
        run_task :uninstall, :cmd=>cmd, :env=>'production'
      end
    end

    describe :uninstall do
      
      it "Uninstalls and updates .gems and .development_gems."

      steps([:cmd, nil], [:env, nil]) { |cmd, env|
        
        demand_string_not_empty cmd
        demand_array_includes %w{production development}, env

        puts_white "Uninstalling: #{cmd}"

        # Let's see if the user choose the right environment
        # for the gem.
        gem_name = cmd.strip.split.first.upcase
        all_gem_names = arr.map { |l| l.strip.split.first }
        demand_array_includes all_gem_names, gem_name
        
        # It's magic time... Uninstall gem, don't use
        # anything other than :system, to retain 'gem uninstall'
        # interactivity, especially during questioning of 
        # gem dependencies.
        ok = system "gem uninstall #{cmd} -a -x -V --backtrace "
        
        return false unless ok
        
        file, arr = eval("GEM_#{env.upcase}_PAIR")

        File.open( file, 'w' ) do |f|
          f.write arr.reject { |l| 
            l.strip.split.first.upcase == gem_name
          }.join("\n")
        end

      }
    end

    # describe :update  do
    #   
    #   it "Installs and updates all gems from manifest (.gems, .development_gems)" 
    #   
    #   steps {

    #     gems_to_install = GEM_MANIFEST_ARRAY

    #     dev_gems = File.join('~/', PRIMARY_APP, '.development_gems' )
    #     gems_to_install = gems_to_install + (dev_gems).file_read.strip.split("\n")

    #     installed =  shell_out('gem list')
    #     if gems_to_install.empty?
    #       puts_white  "No gems to install."
    #     else
    #       gems_to_install.each { |g|
    #         gem_name = g.split.first.strip
    #         if gem_name[/^[a-z0-9]/i] # Starts w/ alpha-numeric character ???
    #           if installed["#{gem_name} ("]
    #             puts_white "Already installed: #{gem_name}"
    #           else
    #             puts_white shell_out( "gem install #{gem_name}")
    #           end
    #         end
    #       }
    #     end    

    #     puts_white {
    #       system('gem update') 
    #     }
    #   }
    # end   
     
end # === namespace :gems
