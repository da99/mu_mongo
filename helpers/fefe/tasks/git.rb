
require 'launchy'
require 'rest_client'

class Git

  include FeFe

  describe :update do
    it "Executes: git add . && git add -u && git status"
    
    steps do
      fefe_run 'sass:compile'
      puts_white( output = shell_out('git add . && git add -u && git status') )
      fefe_run 'sass:delete'
      output['Changes to be committed']
    end
  end

  describe :commit do
    it 'Gathers comment and commits it. Example: git:commit message="My commit." '
    
    steps([:msg]) do |msg|

      comment = demand_string_not_empty msg
        
      if commit_pending?
        puts_white shell_out( 'git commit -m %s ', comment)
        puts_white "COMMITTED: #{comment}"
        true
      else
        puts_red "NO GO: Nothing to commit."
        false
      end
      
    end

  end

  describe :dev_check do
    it "Used to update and commit development checkpoint. Includes the commit comment for you."
    steps do
      run_task :commit, :msg=>'Development checkpoint.'
    end 
  end # === task

  
  describe :push do 
    it "Push code to Heroku. Options: migrate = false"
    steps do

      output = run_task(:update)

      if commit_pending?(output)
        puts_white output
        puts_red "NO GO: You *can't* push, unless you commit."
        return output
      end

      # Check if specs all pass.
      #puts_white capture_all('gem update')
      total, passed, errors = run_task( 'fefe:tests' )
      if total == passed
        raise "#{failed} tests failed."
      else
        puts_white 'All specifications passed.'
      end

      puts_white 'Please wait as code is being pushed to Heroku...'

      push_results = shell_out( 'git push heroku master')
      push_went_ok = push_results[ /deployed to Heroku/i ] && !push_results[ /(error|fail)/i ]
      if !push_went_ok
        puts_red push_results
        return false
      end
      
      puts_white push_results

      app_name = File.basename(Dir.getwd)
      case app_name
        when 'miniuni'
          url = "http://#{app_name}.heroku.com/"
          check_this_url url, /mega/
        when 'megauni'
          url = "http://www.#{app_name}.com/"
          check_this_url url, /megauni/i
          check_this_url "http://www.busynoise.com/", /has moved/
          check_this_url "http://www.busynoise.com/egg/", /has moved/
          check_this_url "http://www.myeggtimer.com/", /new address/
          check_this_url "#{url}busy-noise/", /create_countdown/
          check_this_url "#{url}my-egg-timer/", /egg_template/
        else
          url = "http://www.#{app_name}.com/"
          check_this_url url, /#{app_name}/
      end

      Launchy.open( url )

      true
    end
  end # === task


  private # ===================================================

  def commit_pending?
    run_task(:update, {})
  end

  def check_this_url url, r_text
    begin
      results = RestClient.get( url )
      if results !~ r_text
        puts_red "Could not find #{r_text.inspect} @ #{url}"
      end
    rescue RestClient::ResourceNotFound, RestClient::RequestFailed, RestClient::RequestTimeout
      puts_red "Homepage problem: #{url} - #{$!.message}"
    end
  end
end # === Git

