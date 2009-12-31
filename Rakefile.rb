# Rake.application.options.trace = true

require 'term/ansicolor'

def puts_white msg
  Term::ANSIColor.send(:white) { msg }
end

def puts_red msg
  Term::ANSIColor.send(:red) { msg }
end

def assert_not_empty raw_val
  val = raw_val.is_a?(String) ? raw_val.strip : raw_val;

  if val.nil? || val.empty?
    raise "#{raw_val.inspect} must not be empty"
  end

  val
end

%w{ 
  git
  sass
}.each { |lib|
  require "rake/#{lib}"
}

puts "\n\n"

at_exit do
	puts "\n\n"
end




