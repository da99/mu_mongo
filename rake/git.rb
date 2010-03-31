require 'launchy'
require 'rest_client'


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

def git_commit_pending?
  output = `git status 2>&1`
  case $?.exitstatus
  when 0
    true
  when 1
    false
  else
    raise "Unknown error: exitstatus: #{$?.exitstatus}  -  #{output}"
  end
end

namespace 'git' do
  
  desc 'Executes: git add . && git add -u && git status'
  task :update do 
    sh 'git add . && git add -u'
    system 'git status'
  end
  
  
  desc 'Gathers comment and commits it. Example: git:commit msg="My commit." '
  task :commit => [:update] do
    
    raw_msg = ENV['msg']

    comment = assert_not_empty( raw_msg )
      
    if git_commit_pending?
      sh( 'git commit -m %s ' % comment.inspect )
      puts_white "COMMITTED: #{comment}"
    else
      puts_red "NO GO: Nothing to commit."
    end

  end

  
  desc "Used to update and commit development checkpoint. Includes the commit comment for you."
  task :dev_check do
    ENV['msg'] ||= 'Development checkpoint.'
    Rake::Task['git:commit'].invoke
  end # === task

  
  desc "Prep push code to Heroku."
  task :prep_push do 

    # puts_white 'Updating gems...'
    # `gem update`
    Rake::Task['views:compile'].invoke
		# Rake::Task['tests:all'].invoke
    ENV['msg'] = 'Development checkpoint. (Mustache/css compilation.)'
    Rake::Task['git:dev_check'].invoke
		
		# puts_white "Uploading design document."
		# Rake::Task['db:design_doc_upload'].invoke
    # puts_white `git push heroku`


      # puts_red "Not done."
      # puts_red "First, update gems."
      # puts_red "Then, compile MAB to Mustache."
      # puts_red "Second, run tests."
      # puts_red "Third, if tests pass, update both .gems and .development_gems."
      # puts_red "Fourth, push if tests pass."

      # output = run_task(:update)

      # if commit_pending?(output)
      #   puts_white output
      #   puts_red "NO GO: You *can't* push, unless you commit."
      #   return output
      # end

      # # Check if specs all pass.
      # total, passed, errors = run_task( 'fefe:tests' )
      # if total == passed
      #   raise "#{failed} tests failed."
      # else
      #   puts_white 'All specifications passed.'
      # end

      # puts_white 'Please wait as code is being pushed to Heroku...'

      # push_results = shell_out( 'git push heroku master')
      # push_went_ok = push_results[ /deployed to Heroku/i ] && !push_results[ /(error|fail)/i ]
      # if !push_went_ok
      #   puts_red push_results
      #   return false
      # end
      # 
      # puts_white push_results

      # app_name = File.basename(Dir.getwd)
      # case app_name
      #   when 'miniuni'
      #     url = "http://#{app_name}.heroku.com/"
      #     check_this_url url, /mega/
      #   when 'megauni'
      #     url = "http://www.#{app_name}.com/"
      #     check_this_url url, /megauni/i
      #     check_this_url "http://www.busynoise.com/", /has moved/
      #     check_this_url "http://www.busynoise.com/egg/", /has moved/
      #     check_this_url "http://www.myeggtimer.com/", /new address/
      #     check_this_url "#{url}busy-noise/", /create_countdown/
      #     check_this_url "#{url}my-egg-timer/", /egg_template/
      #   else
      #     url = "http://www.#{app_name}.com/"
      #     check_this_url url, /#{app_name}/
      # end

      # Launchy.open( url )

      # true
  end # === task

  task :push do
    puts `git push webfaction 2>&1`
    puts `ssh da01@da01.webfactional.com "cd ~/megauni && gem update && git pull && rake unicorn:restart" 2>&1`
  end

  
end # === namespace git
