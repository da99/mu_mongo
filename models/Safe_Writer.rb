module String_for_Safe_Writer
  def folder_name 
    File.basename(File.dirname(self))
  end
	
	def name
		File.basename(self)
	end
end

class Safe_Writer

  extend Delegator_DSL
	
  attr_reader :config, :from_file, :write_file
	
  delegate_to 'File',       :expand_path
  delegate_to 'config.ask', :verbose?, :syn_modified_time?
  delegate_to 'config.get',
			:read_folder, :write_folder, 
			:read_file,   :write_file

  def initialize &configs
    @config = Config_Switches.new {
      switch verbose, false
      switch sync_modified_time, false
      arrays :read_folder, :write_folder
      arrays :read_file,   :write_file
    }

    @config.put &configs
  end
      
  def from raw_file
		@from_file = expand_path(raw_file)
		@from_file.extend String_for_Safe_Writer
		
		readable_from_file!
  end

  def write raw_file, raw_content
    @write_file    = expand_path(raw_file)
		@write_file.extend String_for_Safe_Writer

    content = raw_content.to_s

    puts("Writing: #{write_file}") if verbose?
		
		writable_file!( write_file )
		
		File.open( write_file, 'w' ) do |io|
			io.write content
		end
		
		if sync_modified_time? && has_from_file?
			touch( from_file, write_file ) 
		end
  end
  
  def touch *args
		command = args.map { |str| 
			%~touch "#{str}"~
		}.join( ' && ' )
		
		`#{command}`
  end

	def readable_from_file!
		validate_file! :read
	end

	def writable_from_file!
		validate_file! :write
	end

	def validate_file! op
		file         = send("#{op}_file")
		valid_folder = validate_default_true(read_folder, file.folder)
		valid_file   = validate_default_true(read_file, file.name)
			
		unless valid_folder && valid_file
			raise "Invalid file for #{op}: #{file}" 
		end
	end
  
	def validate_default_true validators, val
		return true if validators.empty?
		validate validators, val
	end

	def validate validators, val
		validators.detect { |dator|
				case dator
				when String
					val == dator
				when Regexp
					val =~ dator
				end
			}

	end

end # === class


