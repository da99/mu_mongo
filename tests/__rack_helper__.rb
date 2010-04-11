ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'middleware/Fake_Server'
require 'nokogiri'

class Test::Unit::TestCase

  include Rack::Test::Methods

  def app
    @app ||= begin
               rack    = Rack::Builder.new
               rack.use Fake_Server
               file    = File.expand_path('config.ru')
               content = File.read(file)
               rack.instance_eval(content, file, 1)
               rack.to_app
             end
  end  

end

