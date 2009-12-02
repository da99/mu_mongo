my_app_root     = File.expand_path( File.dirname(__FILE__) )
down_time_file  = File.join(my_app_root , '/helpers/sinatra/maintain')
issue_client    = File.join(my_app_root , '/helpers/app/issue_client')

begin
  
  require( my_app_root + '/megauni' )
  
  if DesignDoc.needs_push_to_db?
    DesignDoc.create_or_update
  end
  
rescue Object => e
  
  require issue_client
  
  begin
    if ENV['RACK_ENV'] != 'development'
      IssueClient.create( 
                         {'PATH_INFO' => __FILE__.to_s, 'HTTP_USER_AGENT' => 'Rack', 'REMOTE_ADDR'=>'127.0.0.1' },
                         Sinatra::Application.environment, 
                         $!
                        )
    end
  rescue Object => e
    raise e if ENV['RACK_ENV'] == 'development'
  end
 
  require down_time_file

end


# Finally, start the app.
run Sinatra::Application
