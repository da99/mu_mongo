require 'pow'
require "highline/import"

if defined? print_this
  raise "Method :print_this already defined."
end

def print_this(*args)
  args.each {|new_line|
    if new_line.empty?
      print "\n"
    else
      print "===>  #{new_line}\n\n" 
    end
  }
end


if defined? check_file_does_not_exist!
  raise "Method :check_file_does_not_exist! already defined."
end

def check_file_does_not_exist!(raw_file_path)
  file_path = raw_file_path.to_s.strip
  raise ArgumentError, "File path to check is empty." if file_path.empty?
  raise ArgumentError, "File: #{file_path} already exists." if File.exists?(file_path )
  false
end


if defined? write_this_file
  raise "Method :write_this_file already defined."
end

def write_this_file(raw_file_path, raw_txt)
  file_path = raw_file_path.to_s.strip
  txt   = raw_txt.to_s.strip

  check_file_does_not_exist!(file_path)

  if ENV['debug']
    puts "::::This would have been written::::"
    puts "::Filename::", file_path
    puts "\n::Content::\n", txt
  else
    File.open( file_path, 'w' ) { |f|
      f.write(txt)
    }
  end
  print_this "Finished writing:\n#{file_path}"  
  print_this "..."
end


# ======================================================================
#                      START DEFINING TASKS
# ======================================================================

namespace :gems do
    desc "Updates all gems for this app."
    task :update => [:install] do
    end
    
    desc "Install all necessary gems."
    task :install do
        if RequiredGems.required_gems.empty?
          print_this "\n>> All gems installed.\n\n"
        else
           Rake::Task["gems:__install__"].invoke
        end
        
        system('gem update')
    end
    
    desc "This is here because I can't figure out conditional Rake tasks. :exit and :return do not work in Rake tasks."
    task :__install__  do
        special_gems = RequiredGems.required_gems.select {|k,v| v }

        if !special_gems.empty?
            print_this "Install these gems first by yourself because they require special instructions:\n"
            special_gems.each { |raw_gem_name, special_instructions|
                print_this "NAME: #{raw_gem_name}"
                print_this "NOTES:"
                print_this special_instructions
                print_this "\n"
            }
            return 
        end


        print_this "\n\n>>> Installing gems:\n\n"

        gem_errors = []

        RequiredGems.required_gems.each { |raw_gem_name, special_instructions| 

            execute_this = %~gem install --no-ri --no-rdoc "#{raw_gem_name.strip}"~
            results = `#{execute_this} 2>&1`
            print_this "\nResults for:    #{execute_this}"
            print_this results
            print_this "\n"
            gem_errors << results if !results[/Successfully installed #{raw_gem_name.strip}/] || $?.exitstatus != 0

        }

        if !gem_errors.empty?
            print_this "\n\nSummary of ERRORS:"
            print_this gem_errors.join("\n\n")
        end

        print_this "  >>>>>>>>>>>> The End <<<<<<<<<<<<<<<<<"

    end # === task :install_all
    
end # === namespace :gems

namespace :git do

  desc "Execute: git add . && git add -u && git status"
  task :update do
    results = `git add . && git add -u && git status`
    print_this results
  end

  desc "Gathers comment and commits it using: git commit -m '[your input]' "
  task :commit do
    new_comment = ask('Enter comment (type "commit" to end it):') { |q|
      q.gather = 'commit'
    }
    results = `git commit -m '#{new_comment.join("\n").gsub("'", "\\\\'")}'`
    print_this results
  end

end # ==== namespace :git

namespace :production do

	namespace :db do
		desc "Migrates database to latest version."
		task :migrate_up do

		end

	end  # === namespace :db

end  # === namespace :production


namespace :spec do

  desc "Run all specs for this app."
  task :run do
    system('reset')
    print_this "Running tests."
    # results = `ruby -S bacon -o TestUnit -a`
    results = `bacon specs/*`
    print_this "Done. The Results:\n\n#{results}"
  end

end # ==== namespace :spec




namespace :model do

  desc 'Display a list of all models.'
  task( :list ) {
    require 'sequel/extensions/inflector'
    print_this ""
    Pow!("models").each { |ele|
      file_basename = File.basename(ele.to_s)
      if ele.file? && file_basename !~ /init.rb$/
        print_this( file_basename.sub('.rb', '').camelize )
      end
    }
  }

  desc "Create a new model in the /model directory. Case and plurality are handled automatically."
  task( :create ) {
    require 'sequel/extensions/inflector' # for String#underscore, etc.
    m         = ask('Name of new model:').strip.camelize.singularize

    file_path = Pow!("models/#{m.underscore}.rb")
    
    txt = <<-EOF
class #{m} < Sequel::Model

  # ==== CONSTANTS =====================================================
  
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  
  
  # ==== HOOKS =========================================================


  # ==== CLASS METHODS =================================================


  # ==== INSTANCE METHODS ==============================================

  def changes_from_editor( params, mem )
    if new?
        self[:owner_id] = mem[:id]
    end
    if [self.owner].include?(mem)
        @current_editor = mem
        @editable_by_editor = []       
    end
    super
  end # === def changes_from_editor

  def validate_new_values
  end # === def validate_new_values

end # === end #{m}
EOF
    write_this_file(file_path, txt)

    if agree("Create a corresponding migration?", false)
      ENV['__new_migration__'] = m
      Rake::Task['migration:create'].invoke
    end

    if agree('Create a corresponding controller?', false)
      ENV['__new_controller__'] = m
      Rake::Task['controller:create'].invoke
    end
    
  }

  desc "Move a model to a scrap area relative to working directory. (Moves controller and views too.)"
  task( :destroy ) do
    require 'sequel/extensions/inflector'
    m = ask('Name of model:').strip.camelize
    scrap_dir = Pow!( ask('Name of scrap directory (default ../nptv_scraps)') { |q| q.default =  '../nptv_scraps' } )
    model_file = Pow!("models/#{m.underscore}.rb")
    action_file = Pow!("actions/#{m.underscore}.rb")
    skins_dir = Pow!("views/skins")
    
    raise "Scraps dir does not exist: #{scrap_dir}" if !scrap_dir.directory?
    raise "Skins dir does not exist: #{skinds_dir}" if !skins_dir.directory?
    ['models', 'views', 'actions'].each do |check_dir|
      raise "#{check_dir.capitalize} dir does not exist in Scrap Dir." if !(scrap_dir / check_dir ).directory?
    end

    exec_and_check = lambda { |comm|
      results = system(comm)
      raise "Something went wrong when executing: #{comm}" if !results
      results
    }

    if model_file.exists?
      print_this "Moving model file: #{model_file}"
      new_model_file = (scrap_dir / "models" / File.basename(model_file) )
      exec_and_check.call "mv #{model_file} #{new_model_file}"

    else
      print_this "Model file not found. Skipping..."
    end

    if action_file.exists?
      print_this "Moving action file: #{action_file}"
      new_action_file = (scrap_dir / "actions" / File.basename(action_file) )
      exec_and_check.call "mv #{action_file} #{new_action_file}"
    else
      print_this "Action file not found. Skipping..."
    end
    
    skins_dir.each { |dir|
      if dir.directory?
        print_this "In directory: #{dir}"
        [ 'new', 'show', 'edit' ].each { |view_name|
          view_file = ( dir / "#{File.basename(model_file).sub('.rb', '')}_#{view_name}.mab")
          if view_file.file?
            scrap_view_dir = ( scrap_dir / 'views' / File.basename(dir) )
            raise "View dir not found in scrap dir: #{scrap_view_dir}" if !scrap_view_dir.directory?
            
            new_view_file = ( scrap_view_dir / File.basename(view_file) )
            raise "New view file already exists. Delete it to continue: #{new_view_file}" if new_view_file.exists?
            
            print_this "Moving view file: #{view_file}"
            exec_and_check.call "mv #{view_file} #{new_view_file}"
          end
        }
      end
    }
    
    migration_dir = Pow!( "migrations" )
    scrap_migration_dir = ( scrap_dir / "migrations" )
    migration_dir.each { |entry|
      if entry.file? && entry.to_s["create_#{m.underscore.pluralize}.rb"]
        new_file = (scrap_migration_dir / File.basename(entry) )
        print_this "Moving migration file: #{entry}"
        exec_and_check.call "mv #{entry} #{new_file}"
      end
    }
  end # ==== task :destroy
  
end # === namespace :model


namespace :migration do

	desc "Create a migration file. Tip: You can use model:create to automatically create migration."
	task( :create ) do

    # Require Sequel in order to use :camelize method
    require 'sequel/extensions/inflector'
    m = (ENV['__new_migration__'] || ask('Name of migration:')).strip.camelize.pluralize
    i = Dir.entries('./migrations').select {|f| f=~ /^\d\d\d\_\w{1,}/}.sort.last.to_i + 1
    padding = '0' * (3 - i.to_s.length)
    file_path = Pow!("migrations/#{padding}#{i}_create_#{m.underscore}.rb")
    raise ArgumentError, "File: #{file_path} already exists." if File.exists?(file_path )

    txt = <<-EOF
class Create#{m} < Sequel::Migration

  def up  
    create_table( :#{m.underscore} ) {
      # === Associations
      primary_key :id
      
      
      # === Attributes
      
      
      # === Date Times
      timestamp   :created_at
      timestamp   :modified_at, :null=>true
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:#{m.underscore}) if table_exists?(:#{m.underscore})
  end

end # === end Create#{m}
EOF
    write_this_file(file_path, txt)
	end # === task :create_migration => "__setup__:env"

end # === namespace :migration


namespace :controller do # ===========================================================================

	desc "Create a controller file. Tip: You can use model:create to automatically create controller."
	task( :create ) do

    # Require Sequel in order to use :camelize method
    require 'sequel/extensions/inflector'
    m = (ENV['__new_controller__'] || ask('Name of controller:')).strip.camelize

    file_path = Pow!("actions/#{m.underscore}.rb")
    raise ArgumentError, "File: #{file_path} already exists." if File.exists?(file_path )

    txt = <<-EOF
controller(:#{m}) do
    
    show
    new
    create
    edit
    update
                          
end # === class #{m}
    
EOF
    write_this_file(file_path, txt)
	end # === task :create 

end # === namespace :controoler


namespace :view do # ===========================================================================


  desc "Change view name."
  task( :update ) do
    old_view_name = ask("Old view name:").strip
    new_view_name = ask("New view name:").strip
    skin_name , skin_dir = MyHelper.get_skin_name_and_dir
    
    old_files = []
    old_files << (skin_dir / "#{old_view_name}.mab")
    old_files << (skin_dir / 'css' / "#{old_view_name}.mab")
    old_files << Pow!("public/js/pages/#{old_view_name}.js")
    
    new_files = []
    old_files << (skin_dir / "#{new_view_name}.mab")
    old_files << (skin_dir / 'css' / "#{new_view_name}.mab")
    old_files << Pow!("public/js/pages/#{new_view_name}.js")
    
    old_files.each_index { |i|
      if old_files[i].exists?
        print_this "Renaming #{old_files[i]} to #{new_files[i]}"
        `mv #{old_files[i]} #{new_files[i]}`
      end
    }
    
    print_this "Done. Don't forget search for all SASS files and change\n#{old_view_name}  ==>  #{new_view_name}"
  end
  
	desc "Create a view file with SASS file (unless it is a partial)."
	task( :create ) do

    # Require Sequel in order to use :camelize method
    require 'sequel/extensions/inflector'
    void_actions = ['create', 'update', 'delete', 'destroy']
    skin_name , skin_dir = MyHelper.get_skin_name_and_dir
    
    controller_name = ask('Name of controller:').strip.underscore
    actions = ask('Separate each action with a space:').split.map { |action_name| action_name.gsub(/[^a-z0-9\-\_]/i, '-').underscore }
    actions.each { |action_name| 
      if void_actions.include?(action_name)
        print_this "... Skipping: #{action_name} ..."
      else
        file_path = Pow!("views/skins/#{skin_name}/#{controller_name}_#{action_name}.mab")
        raise ArgumentError, "File: #{file_path} already exists." if File.exists?(file_path )

        txt = "p { 'Not implemented yet.'} "
        write_this_file(file_path, txt)
        
        # If not a partial, create a corressponding SASS file.
        if !action_name[/\A\_\_/]
          file_path = Pow!("views/skins/#{skin_name}/css/#{controller_name}_#{action_name}.sass")
          raise ArgumentError, "File: #{file_path} already exists." if File.exists?(file_path )

          txt = "@import layout.sass"
          write_this_file(file_path, txt)
        end
      end # === if void_actions.include?(action_name)
    }



	end # === task :create 

end # === namespace :controoler

namespace :db do


	desc "Env: :test, :development."
	task :migrate_up do
		print_this "Migrating..."
		require Pow!('secret_closet')
		Sequel::Migrator.apply( SecretCloset.connect!, Pow!('migrations') )
		print_this "Done."		
	end # === 


	desc "Delete all tables, migrate up, and create default data."
	task :reset!  do
	
	    raise ArgumentError, "This task not allowed in :production" unless Pow!.to_s =~ /\/home\/da01/
	    
        print_this '', 'Setting up...'
        
        require 'sequel/extensions/migration' 
        require Pow!('secret_closet')
        
	    print_this '', "Reseting database..."
	    SecretCloset.connect!
        Sequel::Migrator.apply( SecretCloset.connection, Pow!('migrations'), 0 )
        Rake::Task["db:migrate_up"].invoke
        print_this( "Finished resetting database.")
	end # ===
	
end # ==== :namespace: db

namespace :doc do
    desc "Generate documentation."
    task :generate do
        ignore_files = File.read(".gitignore").map { |l| 
                          new_l = l.strip
                          ( new_l = new_l.sub('*','') + '$' ) if new_l =~ /\*/
                          ( new_l = nil ) if new_l =~ /\#/ || new_l.empty?
                          new_l
                       }.compact.join("|").gsub( /^\/|\/$/, '') # take out any beginning/trailing slashes

        ignore_files +=  '|spec_it.rb|spec\/'  # add file 'spec_it.rb' and dir 'spec/'

        system "rdoc -U -x '#{ignore_files}' "
        system "echo 'ignored files/dirs: " + ignore_files.split('|').join("\n") + "' "    
    end # === task
end # === namespace :doc

namespace :miscell do
    task :capture do
        raise "No command saved to variable: ruby" if ENV['ruby'].strip.empty?
        print_this "###"
        print_this "### ruby #{ENV['ruby']}"
        print_this '###'

        `ruby #{ENV['ruby']} > /tmp/spec_it_output.txt`
        `gedit /tmp/spec_it_output.txt`
        `rm /tmp/spec_it_output.txt` 
    end
end

class MyHelper
  def self.get_skin_name_and_dir
    skin_name = ask('Skin name. (Default is "jinx"):' ) { |q| q.default =  'jinx' }
    skin_dir = Pow!("views/skins/#{skin_name}")
    raise "Skin dir does not exist: views/skins/#{skin_name}" unless skin_dir.exists?  
    [skin_name, skin_dir]
  end
end

class RequiredGems

    ENV_PROD = :production
    ENV_DEV = :development
    
  # ==========================================================
  # Run app methods.
  # ==========================================================
  # ==========================================================

    def self.development?
        File.expand_path('.') =~ /\/home\/da01\//
    end
  
  def self.gems
    { ENV_PROD =>  {    
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
        
        'hpricot' => nil,
        'tzinfo' => nil,
        'tmail' => nil,
        
        'chriseppstein-compass' => nil,
        'chriseppstein-compass-960-plugin' => nil,
        
        'mattetti-multibyte' => nil,  # Use this instead of ActiveSupport
        'markaby' => nil
        

        # 'htmldiff' => ['http://github.com/myobie/htmldiff/tree/master, http://github.com/evilchelu/braid/wikis/home']
      } ,   

       ENV_DEV => {
              # 'mongrel' => nil,
              'optiflag' => nil,
              'rspec' => nil, 
              'mocha' => nil, 
              'test-spec' => nil, 
              # 'capistrano' => nil,
                'wirble' => nil,
                'rack-test' => nil,
                'bacon' => nil
            }
    }
  end
  
    def self.required_gems
        gems_that_are_required = self.gems[ENV_PROD]

        if self.development? 
          gems_that_are_required = gems_that_are_required.merge( self.gems[ENV_DEV] )
        end
        
        installed_gems  = `gem list`.split.reject {|name| name =~ /^\(/ }.map { |name| name.downcase }.uniq
        
        install_these_gems = gems_that_are_required.reject { |new_gem, special_instructions|
            gem_name = new_gem.strip.downcase
            raise "Empty gem name: #{new_gem.inspect}" if gem_name.empty? 
            installed_gems.include?(gem_name) 
        }
        
        install_these_gems
    end
  
  def self.install_gems
    # command = .jruby? ? "jruby -S gem install " : "ruby gem install"
    special_gems = []
    results = []
    
    raise ArguementError, "This program can not handle C-based Ruby gems yet." unless jruby?

    results = gems[ENV_PROD].to_a.map { |gem_name, instructions| 
                unless instructions
                  "jruby -S gem install #{gem_name}"
                else
                  special_gems << gem_name
                  nil
                end
              }

    [ special_gems, results.compact ]
  end


  
  
end # RequiredGems -------------------------------------------------------------------------


