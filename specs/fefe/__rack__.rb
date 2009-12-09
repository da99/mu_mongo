require 'rack/test'
ENV['RACK_ENV'] = 'test'

require File.expand_path('.').split('/').last  # <-- your sinatra app
set :environment, :test


module FeFe_Test

  include Rack::Test::Methods
   
  def app
    Sinatra::Application
  end   

  def ssl_hash
    {'HTTP_X_FORWARDED_PROTO' => 'https'}
  end

  def last_response_should_be_xml
    demand_equal 'application/xml;charset=utf-8', last_response.headers['Content-Type']
  end

  def follow_ssl_redirect!
    follow_redirect!
    follow_redirect!
  end

  def log_in_member
    mem = Member.by_username('regular-member-1')
    demand_false( mem.has_power_of?( :ADMIN ) )
    post '/log-in/', {:username=>mem.usernames.first, :password=>'regular-password-1'}, ssl_hash
    follow_ssl_redirect!
    demand_regex_match /my-work/, last_request.fullpath
  end

  def log_in_admin
    mem = Member.by_username('admin-member-1')
    demand_true mem.has_power_of?( :ADMIN )
    post '/log-in/', {:username=>mem.usernames.first, :password=>'admin-password-1'}, ssl_hash
    follow_ssl_redirect!
    demand_regex_match /my-work/, last_request.fullpath
  end

  
end # ======== FeFe_Test
