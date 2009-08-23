# ====================================================================================
# ====================================================================================
class WorkingNotice

  include Blato
  
  bla :start, 'Puts up a maintenence page for all actions. Takes into account AJAX and POST requests.' do
    
    maintain_file = Pow('helpers/maintain.rb')
    raise "File not found: #{maintain_file}" if !maintain_file.exists?
    
    # Copy file to helpers/sinatra
    maintain_file.move_to( Pow('helpers/sinatra/maintain.rb'))
    
    # add_then_commit_and_push 
    Rake::Task['git:update'].invoke
    
    commit_results = `git commit -m "Added temporary maintainence page." 2>&1`
    shout commit_results
    
    push_results = `git push heroku master  2>&1`
    shout push_results
    
  end # === task :start
  
  bla :over, 'Takes down maintence page.' do
  
    # Delete file from helpers/sinatra
    maintain_file = Pow('helpers/sinatra/maintain.rb')
    raise "File does not exists: #{maintain_file}" if !maintain_file.exists?
    maintain_file.move_to(Pow('helpers'))
    
    # add_then_commit_and_push 
    Rake::Task['git:update'].invoke
    
    commit_results = `git commit -m "Removed temporary maintainence page." 2>&1`
    shout commit_results
    
    push_results = `git push heroku master  2>&1`
    shout push_results
    
  end # === task :over
  
end # === namespace :maintain

