my_app_root = File.expand_path( File.dirname(__FILE__) )

class Sinatroad
  def self.report! sinatra_application
    data = {:request => sinatra_application.request,
     :environment => sinatra_application.env,
     :session => sinatra_application.session.inspect,
     :backtrace => sinatra_application.request.env['sinatra.error'].backtrace,
     :api_key => '348c643b17e30643b8d748dfc9f9ce7a', 
     :error_message => sinatra_application.request.env['sinatra.error'].message
    }
 
      
    begin
      RestClient.post "http://da01.hoptoadapp.com/notices", data
    rescue Exception => e
      e.response
    end
  end
end

begin
  raise "show maintainence page"  if File.exists?(my_app_root + '/helpers/sinatra/maintain.rb')
  require( my_app_root + '/megauni.rb' )
rescue
  $KCODE = 'UTF8'
  require 'rubygems'
  require 'sinatra'
  require( my_app_root + '/helpers' + ['/maintain', '/sinatra/maintain'].detect { |f| File.exists?(my_app_root+'/helpers' + f + '.rb') })
end

run Sinatra::Application

