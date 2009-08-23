class Dev

  include Blato
  
  bla :capture, "Captures output given to 'ruby'" do
      raise "No command saved to variable: ruby" if ENV['ruby'].strip.empty?
      shout "###"
      shout "### ruby #{ENV['ruby']}"
      shout '###'

      `ruby #{ENV['ruby']} > /tmp/spec_it_output.txt`
      `gedit /tmp/spec_it_output.txt`
      `rm /tmp/spec_it_output.txt` 
  end
end
