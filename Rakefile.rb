# Rake.application.options.trace = true

%w{
	Color_Puts
  kernel
}.each do |name|
	require "helpers/app/#{name}"
end

include Color_Puts

def assert_not_empty raw_val
  val = raw_val.is_a?(String) ? raw_val.strip : raw_val;
  raise "#{raw_val.inspect} must not be empty" if val.nil? || val.empty?
  val
end

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
}.each { |lib|
  require "rake/#{lib}"
}

puts "\n\n"

at_exit do
	puts "\n\n"
end




