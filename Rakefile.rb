# Rake.application.options.trace = true


# If requested, install development + production gems and EXIT.
if ARGV === %w{ install all}
  # Get list of gem names
  curr_gems = `gem list`.split("\n")

  # Strip out version info.
  # rack (1.5) ==> rack
  curr_gems = curr_gems.map { |line|  line.split('(').first.strip }

  # Update gem system.
  cmd = "gem update --system"
  puts "Updating with: #{cmd}"
  puts `#{cmd}`


  # Install each gem is not already installed
  file_contents = File.read('.gems') + "\n" + File.read(".development_gems")

  cmds = file_contents.split("\n").compact.uniq.reject { |line|
    gem_name = line.split.first
    is_comment = line.strip['#']
    is_installed = curr_gems.include?(gem_name)
    empty_line = line.strip.empty?

    unless is_comment || is_installed || empty_line
      puts "Installing: #{line}"
      puts(results = `gem install --no-rdoc --no-ri #{line}`)
      puts ""
      exit if results === ''
    end
  }
  puts "Finished install development gems."
  exit
end


require "helpers/app/Color_Puts"
require "helpers/app/kernel"


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
  models
  gems
}.each { |lib|
  require "rake/#{lib}"
}

puts "\n\n"

at_exit do
  puts "\n\n"
end





