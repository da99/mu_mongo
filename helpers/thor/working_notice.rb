# ====================================================================================
# ====================================================================================
class WorkingNotice < Thor

  include CoreFuncs
  
  desc :start, 'Puts up a maintenence page for all actions. Takes into account AJAX and POST requests.'
  def start
    
    maintain_file = Pow('helpers/maintain.rb')
    raise "File not found: #{maintain_file}" if !maintain_file.exists?
    
    # Copy file to helpers/sinatra
    maintain_file.move_to( Pow('helpers/sinatra/maintain.rb'))
    
    # add_then_commit_and_push 
    invoke 'git:update'
    
    commit_results = capture_all( 'git commit -m "Added temporary maintainence page."' )
    shout commit_results
    
    push_results = capture_all('git push heroku master')
    shout push_results
    
  end # === task :start
  
  desc :over, 'Takes down maintence page.'
  def over
  
    # Delete file from helpers/sinatra
    maintain_file = Pow('helpers/sinatra/maintain.rb')
    raise "File does not exists: #{maintain_file}" if !maintain_file.exists?
    maintain_file.move_to(Pow('helpers'))
    
    # add_then_commit_and_push 
    invoke 'git:update'
    
    commit_results = capture_all( 'git commit -m "Removed temporary maintainence page."')
    shout commit_results
    
    push_results = capture_all('git push heroku master')
    shout push_results
    
  end # === task :over
  
end # === namespace :maintain

