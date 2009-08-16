my_app_root = File.expand_path( File.dirname(__FILE__) )


    
    
begin
  raise "show maintainence page"  if File.exists?(my_app_root + '/helpers/sinatra/maintain.rb')
  require( my_app_root + '/megauni.rb' )
rescue
  $KCODE = 'UTF8'
  require 'rubygems'
  require 'sinatra'
  require( my_app_root + '/helpers' + ['/maintain', '/sinatra/maintain'].detect { |f| File.exists?(my_app_root+'/helpers' + f + '.rb') })
  
  require 'net/http'
  require 'rack_hoptoad'
  rh = Rack::HoptoadNotifier.new 'nil'
 
  rh.send(:send_to_hoptoad, :notice=>{
    :api_key => '05d03bbc87077117598fd437ce0caaa1',
    :error_class => $!.class.name,
    :error_message => "#{$!.class.name}: #{$!.message}",
    :backtrace => $!.backtrace.reject {|f| f !~ /#{File.expand_path('.')}/},
    :request => {},
    :session => {},
    :environment => {'message'=>'App could not start.'}
  })

end

run Sinatra::Application

