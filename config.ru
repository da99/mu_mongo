
my_app_root = File.expand_path( File.dirname(__FILE__) )

begin
  raise "show maintainence page"  if File.exists?(my_app_root + '/helpers/sinatra/maintain.rb')
  require( my_app_root + '/megauni' )
rescue

  begin
    raise if Sinatra::Application.environment.to_sym === :development

    $KCODE = 'UTF8'
    require 'rubygems'
    require 'sinatra'
    require( my_app_root + '/helpers' + ['/maintain', '/sinatra/maintain'].detect { |f| File.exists?(my_app_root+'/helpers' + f + '.rb') })

    require( my_app_root + '/helpers/issue_client' )
    faux_env = {'PATH_INFO' => __FILE__.to_s, 'HTTP_USER_AGENT' => 'Rack', 'REMOTE_ADDR'=>'127.0.0.1' }
    IssueClient.create( faux_env, Sinatra::Application.environment, $!)
  rescue
    dev_env = File.expand_path('.')['home/da01'] 
		raise if dev_env
    before {
      halt "Error occurred. Come back later."
    }
  end

end

run Sinatra::Application
