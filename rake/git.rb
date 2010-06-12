require 'launchy'
require 'rest_client'

MAX_DB_SIZE_IN_MB = 12.0

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
    sh 'git status'
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

    Rake::Task['views:compile'].invoke
    ENV['msg'] = 'Development checkpoint. (Mustache/css compilation.)'
    Rake::Task['git:dev_check'].invoke
		

    # # Check if specs all pass.
    # total, passed, errors = run_task( 'fefe:tests' )
    # if total == passed
    #   raise "#{failed} tests failed."
    # else
    #   puts_white 'All specifications passed.'
    # end

  end # === task

  task :push do
    Rake::Task['git:prep_push'].invoke
    
    puts_white "Checking size of MongoDB account..."
    db_size = `mongo flame.mongohq.com:27024/mu01 -u da01 -p isle569vxwo103  --eval "db.stats().storageSize / 1024 / 1024;" 2>&1`.strip.split.last.to_f
    if db_size > MAX_DB_SIZE_IN_MB 
      puts_red "DB Size too big: #{db_size} MB"
    else
      puts_white "DB Size is ok: #{db_size} MB"
      
      puts_white "Updating gems on Heroku..."
      results = `heroku console "IO.popen('gem update 2>&1') { |io| io.gets }" 2>&1`
      if results['ERROR']
        puts_red results
        exit
      else
        puts_white results
        puts_white "Pushing code to Heroku..."
        sh('git push heroku master')
        sh('heroku open')
      end

    end
  end

  
end # === namespace git
