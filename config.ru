my_app_root = File.expand_path( File.dirname(__FILE__) )

    
begin
  raise "show maintainence page"  if File.exists?(my_app_root + '/helpers/sinatra/maintain.rb')
  require( my_app_root + '/megauni' )
rescue
  $KCODE = 'UTF8'
  require 'rubygems'
  require 'sinatra'
  require( my_app_root + '/helpers' + ['/maintain', '/sinatra/maintain'].detect { |f| File.exists?(my_app_root+'/helpers' + f + '.rb') })
  
  require( my_app_root + '/helpers/sinatra/post_error' ) 
#  faux_env = {'PATH_INFO' => __FILE__.to_s, 'HTTP_USER_AGENT' => self.inspect, 'REMOTE_ADDR'=>'127.0.0.1' }
  info = ( $! ? [ $! ]  : ['Unknown error.', 'Exception not captured.'] )
#  IssueClient.create( faux_env, Sinatra::Application.environment, *info) 
  faux_env = {'PATH_INFO' => __FILE__.to_s, 'HTTP_USER_AGENT' => 'heroku', 'REMOTE_ADDR'=>'127.0.0.1' }
  IssueClient.create( faux_env, :production, $!) 
end

run Sinatra::Application

