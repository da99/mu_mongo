require 'sinatra'


my_app_root = File.expand_path( File.dirname(__FILE__) )

set :environment, :production
 
require( my_app_root + '/megauni.rb' )

run Sinatra::Application
