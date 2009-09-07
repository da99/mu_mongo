
require 'launchy'
require 'rest_client'

class Git

  include Blato
  
  def commit_pending?(raw_out)
    output = (raw_out || capture_task(:update) )
    output['nothing to commit'] ?
      false :
      output  
  end
  
  def check_this_url url, r_text
    begin
      results = RestClient.get( url ) 
      if results !~ r_text
        shout "Could not find #{r_text.inspect} @ #{url}"
      end
    rescue RestClient::ResourceNotFound, RestClient::RequestFailed, RestClient::RequestTimeout
      shout "Homepage problem: #{url} - #{$!.message}"
    end
  end
  
  bla :update, "Executes: git add . && git add -u && git status" do
    invoke 'sass:compile'
    invoke 'run:pyc_sweep'
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
       "Push code to Heroku. Options: open_browser = true, migrate = false" ) do |*args|

    migrate, open_browser = args
   
    # Check if specs all pass.
    whisper capture('gem update')
    spec_results = capture_task('spec:run').strip
    last_msg = spec_results.split("\n").last
    if !( last_msg['0 failures'] && last_msg['0 errors'] )
      shout spec_results
      exit
    else
      whisper 'All specifications passed.'
    end

    output = capture_task(:update)
    
    if commit_pending?(output) 
      whisper output 
      shout "NO GO: You *can't* push, unless you commit."    
    else
      
      shout 'Please wait as code is being pushed to Heroku...', :yellow
      
      push_results =  capture( 'git push heroku master')
      if push_results[ /deployed to Heroku/i ] && !push_results[ /(error|fail)/i ]
        shout push_results, :white
      else
        shout push_results
      end
      
      if migrate
        shout 'Migrating on Heroku...'
        migrate_results = `heroku rake production:db:migrate_up`
        raise "Problem on executing migrate:up on Heroku." if migrate_results[/aborted/i]
        shout migrate_results
        
        shout 'Restarting app servers.'
        shout `heroku restart`
      end
      

      app_name = File.basename(Pow().to_s)
      case app_name
        when 'miniuni'
          url = "http://#{app_name}.heroku.com/"
          check_this_url url, /mega/
        when 'megauni'
          url = "http://www.#{app_name}.com/"
          check_this_url url, /megauni/i
          check_this_url "http://www.busynoise.com/", /has moved/
          check_this_url "http://www.myeggtimer.com/", /new address/
          check_this_url "#{url}busy-noise/", /create_countdown/
          check_this_url "#{url}my-egg-timer/", /egg_template/
        else
          url = "http://www.#{app_name}.com/"
          check_this_url url, /#{app_name}/
      end
      
      if open_browser || open_browser.nil?      
        Launchy.open( url )
      end

    end # === else
    
  end # === task
  
  bla :push_and_migrate_production, "Pushes code to Heroku. Migrates on the server side. Opens browser." do
    invoke(:push, :migrate=>true )
  end 
  
end # === Git



