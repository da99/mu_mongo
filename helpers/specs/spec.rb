require File.expand_path('.').split('/').last  # <-- your sinatra app
require 'rack/test'

ENV['RACK_ENV'] = 'test'
set :environment, :test

class Bacon::Context
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end
end

