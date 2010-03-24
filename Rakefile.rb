# Rake.application.options.trace = true

%w{
  Color_Puts
  kernel
}.each do |name|
  require "helpers/app/#{name}"
end

include Color_Puts

require 'models/FiDi'

def compile_for_production
  spaces = %w{ sass mab xml }
  
  spaces.each { |space|
    Rake::Task["#{space}:compile"].invoke
  }
  
  yield
  
  spaces.each { |space|
    Rake::Task["#{space}:cleanup"].invoke
  }
end

%w{ 
  git
  sass
  mab
  xml
  tests
  db
  views
  my_computer
  server
  gems
  models
}.each { |lib|
  require "rake/#{lib}"
}

puts "\n\n"

at_exit do
  puts "\n\n"
end




