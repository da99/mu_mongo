require File.expand_path('.').split('/').last  # <-- your sinatra app
require 'rack/test'

set :environment, :test

