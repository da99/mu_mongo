class Views

	include FeFe

	describe :create do
		
		it 'Creates a template with corresponding view file.'
		
		steps([:name, nil], [:lang, 'English']) do |name, lang|
			
			demand_regex_match( /\A[a-zA-Z\-\_0-9]+\Z/, name)
      wdir = '~/' + File.basename(Dir.getwd)
			dir  = File.join(wdir,  'mab')
			mab  = File.join(wdir, 'templates', lang, 'mab', name + '.rb')
      sass = File.join(wdir, 'templates', lang, 'sass', name + '.sass')
			view = File.join(wdir, 'views', name + '.rb')
			created = []
			already = []

			templates = {}
			templates[mab] = %~
# VIEW #{view}
# SASS #{sass}
# NAME #{name}

div.content! { 
  

  
} # === div.content!

partial('__nav_bar')

~.lstrip

			templates[view] = %~
# MAB   #{mab}
# SASS  #{sass}
# NAME  #{name}

class #{name} < View_Base

  def title 
    '...'
  end
	
end # === #{name} ~.lstrip

      if sass
        templates[sass] = %~
// MAB  #{mab}
// VIEW #{view}
// NAME #{name}

@import layout.sass


~.lstrip
      end

			templates.each do |file, content|
			  full_path = file.expand_path	
				if File.file?(full_path)
					puts_white 'Already existed:'
				else
					# Create file.
					File.open( full_path, 'w') do |file_io|
						file_io.puts content
					end
					puts_white 'Created:'
				end
				
				puts_white file
				
			end

		end # === steps
	end # === describe

end # === Views

