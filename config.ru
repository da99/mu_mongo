my_app_root = File.expand_path( File.dirname(__FILE__) )

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

