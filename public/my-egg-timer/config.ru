require 'sinatra'


my_app_root = File.expand_path( File.dirname(__FILE__) )

set :environment, :production
 
require( my_app_root + '/egg.rb' )

run Sinatra::Application
