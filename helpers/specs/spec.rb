require File.expand_path('.').split('/').last  # <-- your sinatra app
require 'rack/test'
ENV['RACK_ENV'] = 'test'
set :environment, :test



class Bacon::Context
  include Rack::Test::Methods
 
  def app
    Sinatra::Application
  end

  def ssl_hash
    {'HTTP_X_FORWARDED_PROTO' => 'https'}
  end

  def last_response_should_be_xml
    last_response.headers['Content-Type'].should.be == 'application/xml;charset=utf-8'
  end

  def follow_ssl_redirect!
    follow_redirect!
    follow_redirect!
  end

  def log_in_member
    mem = Member.get_by_id('regular-member-1')
    mem.should.not.has_power_of :ADMIN
    post '/log-in/', {:username=>mem.usernames.first, :password=>'regular-password'}, ssl_hash
    follow_ssl_redirect!
    last_request.fullpath.should =~ /my/
  end

  def log_in_admin
    mem = Member.get_by_id('admin-member-1')
    mem.should.has_power_of :ADMIN
    post '/log-in/', {:username=>mem.usernames.first, :password=>'admin-password'}, ssl_hash
    follow_ssl_redirect!
    last_request.fullpath.should =~ /my/
  end

end

