  # Drop this in ~/.boson/commands/brain.rb
  # The module name can be anything but it makes sense to name it the same as the file.
  # The module is evaluated under Boson::Commands
  module Brain
    # Help Brain live his dream
    def take_over(destination)
      puts "Pinky, it's time to take over the #{destination}!"
    end
    
    # When do we visit the moon?
    def visit_moon(datetime=nil)
      puts "Now: #{datetime || Time.now}"
    end
  end

