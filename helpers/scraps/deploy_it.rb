set :keep_releases, 3

set :application, "busynoise"
set :domain, "busynoise.com" # The URL for your app.
set :user, "busynoi"                  # Your HostingRails username
set :repository,  "#{user}@#{domain}:/home/#{user}/git/#{application}" # The repository location for git+ssh access

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :scm, :git
set :scm_username, user
set :runner, user # http://groups.google.com/group/capistrano/ -> search: runner
set :use_sudo, false # HostingRails users don't have sudo access
set :branch, "master"
set :deploy_to, "/home/#{user}/#{application}"# Where on the server your app will be deployed
set :deploy_via, :remote_cache 
# set :deploy_via, :checkout  # For this tutorial, svn checkout will be the deployment method, but check out :remote_cache in the future
# set :git_shallow_clone, 1
# set :chmod755, "app config db lib public vendor script script/* public/disp*"  	# Some files that will need proper permissions

ssh_options[:keys] = %w(/home/da01/.ssh/id_dsa)            # If you are using ssh_keys
ssh_options[:forward_agent] = true

# The following line is import for Windows and some other OSes.
# http://groups.google.com/group/capistrano/browse_thread/thread/13b029f75b61c09dnt.
# Safe to leave in for any OS.
default_run_options[:pty] = true  


# Dependencies -------------------------------------------------------------------------
if ARGV.last.eql?( 'deploy' ) 
  # The following is run:
  #  * AFTER the config files have been set up.
  #  * BEFORE creating the new /current release path.
  #  * as part of 'deploy:check' while runing 'deploy'.
  depend :remote, :match, "ruby #{release_path}/command_line.rb -check_tables_for_production", /Migration completed for \:production environment/
  depend :remote, :match, "ruby #{release_path}/config/check_gems.rb", /All gems installed/
else
  after 'deploy:check' do
    puts ">>>>>>>> Check for :production tables did *not* occur because this is not 'cap deploy'. <<<<<<<<<<<<<<<<<<<" 
  end
end
# --------------------------------------------------------------------------------------------


# Put in task hooks here. ----------------------------------------------------------
before 'deploy', 'deploy:git_push_code'
before 'deploy:symlink', 'deploy:check'
after "deploy:update_code", "deploy:symlink_to_config_file"
after "deploy:web:disable", 'deploy:symlink_to_index_page'
after 'deploy:web:enable', 'deploy:remove_symlink_to_index_page'
after 'deploy', 'deploy:cleanup'
after 'deploy', 'cache:them'
# after 'deploy', 'deploy:force_symlink_to_index_page'
# -----------------------------------------------------------------------------------------


# Tasks ---------------------------------------------------------------------------------
namespace :cache do
  desc "Cache pages by using wget with the --spider option."
  task :them, :role=>:app do
    system "wget --spider http://www.#{domain}/"
    system "wget --spider http://www.#{domain}/stylesheets/index.css"
    system "wget --spider http://www.#{domain}/egg"
    system "wget --spider http://www.#{domain}/stylesheets/eggtimer_index.css"
  end
end


namespace :deploy do

  desc "Restart app via 'tmp/restart.txt'."
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "'#{t}' task does not apply when using  Passenger."
      task t, :roles => :app do
    end
  end
  
  desc "Push code to remote repository using git-push"
  task :git_push_code, :roles=>:app do
    system "git push"
  end
  
   desc "Make symlink for sensitive config files for production."
   task :symlink_to_config_file, :roles => :app do
     run "ln -nfs ~/.busynoise.config #{release_path}/config/config_it.rb"
   end
  
  desc 'Symlink maintenance page to index.html'
  task :symlink_to_index_page, :roles => :app do
    notice_page   = File.expand_path('~/shared/system/maintenance.html')
    page_500        = "#{current_path}/public/500.html"
    new_page      = "#{current_path}/public/index.html"
    run("ln -nfs #{notice_page} #{new_page}") if File.exists?(notice_page) && !File.exists?(new_page)
    run("ln -nfs #{page_500} #{new_page}") if File.exists?(notice_page) && !File.exists?(new_page) && File.exists?(page_500)
  end
  
  desc 'Force index.html to be maintenance.'
  task :force_symlink_to_index_page, :roles=>:app do
    existing_page = "#{current_path}/public/maintanence.index.html"
    new_page = "#{current_path}/public/index.html"
    run("ln -nfs #{existing_page} #{new_page}") 
  end
  
  desc 'Remove symlink maintenance page to index.html'
  task :remove_symlink_to_index_page, :roles => :app do
    index_page = "#{release_path}/public/index.html"
    run("rm --verbose #{index_page}") if File.symlink?(index_page)
  end
  
end # namespace
 
# end tasks -------------------------------------------------------------------------------


