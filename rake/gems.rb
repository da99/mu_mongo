GEM_MANIFEST           = File.expand_path(File.join('~/', PRIMARY_APP, '.gems'))
GEM_MANIFEST_ARRAY     = File.read(GEM_MANIFEST).strip.split("\n")
GEM_PRODUCTION_PAIR    = [GEM_MANIFEST, GEM_MANIFEST_ARRAY]

GEM_MANIFEST_DEV       = GEM_MANIFEST.sub('.gems', '.development_gems')
GEM_MANIFEST_DEV_ARRAY = File.read(GEM_MANIFEST_DEV).strip.split("\n")
GEM_DEVELOPMENT_PAIR   = [GEM_MANIFEST_DEV, GEM_MANIFEST_DEV_ARRAY]

namespace :gem do 
    
  desc 'Installs a gem for the development environment. Uses ENV["cmd"]'
  task :development_install do
    ENV['env'] = 'development'
    Rake::Task['gem:install']
  end

  
  desc 'It install a gem for the production environment. Uses ENV["cmd"]'
  task :production_install do
    ENV['env'] = 'production'
    Rake::Task['gem:install']
  end

    
  desc "Install a gem and update appropriate gem manifest. Uses ENV['cmd'] and ENV['env']"
  task :install do
    
    cmd = ENV['cmd']
    env = ENV['env']
    
    assert_included %w{production development}, env
    command = assert_not_empty(cmd)

    puts_white "Installing: #{command}"

    sh "gem install --no-ri --no-rdoc --backtrace #{command}"

    file , arr = eval("GEM_#{env.upcase}_PAIR")

    gem_name = command.strip.split.first
    new_arr = arr.reject { |g| g.strip.split.first.upcase == gem_name.upcase } 
    new_arr << command
    File.open(file, 'w') { |f|
      f.write new_arr.join("\n")
    }

  end

    
  desc 'Uninstalls a gem in the .development_gems file.'
  task :development_uninstall do
    ENV['env']
    Rake::Task['gem:uninstall']
  end

    
  desc 'Uninstalls a gem in the .production_gems file.'
  task :production_uninstall do
    ENV['env'] = 'production'
    Rake::Task['gem:uninstall']
  end

    
  desc "Uninstalls and updates .gems and .development_gems."
  task :uninstall do

    cmd = ENV['cmd']
    env = ENV['env']



    assert_not_empty cmd
    assert_included  %w{production development}, env

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
    sh "gem uninstall #{cmd} -a -x -V --backtrace "

    file, arr = eval("GEM_#{env.upcase}_PAIR")

    File.open( file, 'w' ) do |f|
      f.write arr.reject { |l| 
        l.strip.split.first.upcase == gem_name
      }.join("\n")
    end

  end

  
  desc "Installs and updates all gems from manifest (.gems, .development_gems)" 
  task :update  do

    gems_to_install = GEM_MANIFEST_ARRAY

    dev_gems        = File.join('~/', PRIMARY_APP, '.development_gems' )
    gems_to_install = gems_to_install + File.read(dev_gems).strip.split("\n")

    installed = `gem list`
    if gems_to_install.empty?
      puts_white  "No gems to install."
    else
      gems_to_install.each { |g|
        gem_name = g.split.first.strip
        if gem_name[/^[a-z0-9]/i] # Starts w/ alpha-numeric character ???
          if installed["#{gem_name} ("]
            puts_white "Already installed: #{gem_name}"
          else
            sh( "gem install #{gem_name}" )
          end
        end
      }
    end    

    sh('gem update') 
  end   
     
end # === namespace :gem
