

class Git

  include Blato
  
  def commit_pending?(raw_out)
    output = (raw_out || capture_task(:update) )
    output['nothing to commit'] ?
      false :
      output  
  end
  
  
  bla :update, "Executes: git add . && git add -u && git status" do
    invoke 'sass:compile'
    shout capture( 'git add . && git add -u && git status' ), :white
    invoke 'sass:delete'    
  end

  bla :commit, {:msg=>[String, nil]}, 'Gathers comment and commits it. Example: rake git:commit message="My commit." ' do |*args|
    msg = args.first
    output = capture_task(:update)
    whisper output
    if commit_pending?(output)
      raw_comment = (msg || HighLine.new.ask("===> " + Blato.colorize_text('Enter one line comment:', :white)) )
      whisper( capture( ' git commit -m %s ', raw_comment  ) )
      shout "COMMITTED: #{raw_comment}",  :white
    else
      shout "NO GO: Nothing to commit."
    end
  end
  
  bla :dev_check, "Used to update and commit development checkpoint. Includes the commit comment for you." do
    invoke :commit, 'Development checkpoint.'
  end # === task    
  
  bla( :push, 
       { :migrate=>false,  :open_browser=>true }, 
       "Push code to Heroku. Options: open_browser = true, migrate = false" ) do

    output = capture_task(:update)
    
    if commit_pending?(output) 
      whisper output 
      shout "NO GO: You *can't* push, unless you commit."    
    else
      shout 'Please wait as code is being pushed to Heroku...', :blue
      shout capture( 'git push heroku master')
      
      if migrate
        shout 'Migrating on Heroku...'
        migrate_results = `heroku rake produciton:db:migrate_up`
        raise "Problem on executing migrate:up on Heroku." if migrate_results[/aborted/i]
        shout migrate_results
        
        shout 'Restarting app servers.'
        shout `heroku restart`
        `heroku open`
      end
      
      `heroku open` if open_browser
    end
    
  end # === task
  
  bla :push_and_migrate, "Pushes code to Heroku. Migrates on the server side. Opens browser." do
    invoke(:push, :migrate=>true )
  end 
  
end # === Git



