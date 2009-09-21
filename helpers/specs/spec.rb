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
    mem = Member.order(:id).limit(1,1).first
    mem.should.not.has_power_of :ADMIN
    post '/log-in/', {:username=>mem.usernames.first[:username], :password=>'myuni4vr'}, ssl_hash
    follow_ssl_redirect!
    last_request.fullpath.should.not =~ /log\-in/
  end

  def log_in_admin
    mem = Member.order(:id).first
    mem.should.has_power_of :ADMIN
    post '/log-in/', {:username=>mem.usernames.first[:username], :password=>'myuni4vr'}, 'HTTP_X_FORWARDED_PROTO' => 'https'
    follow_ssl_redirect!
    last_request.fullpath.should.not =~ /log\-in/
  end

end

