class Views

	include FeFe

	describe :create do
		
		it 'Creates a template with corresponding view file.'
		
		steps([:name, nil], [:lang, 'english']) do |name, lang|
			
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

class #{name} < Bunny_Mustache

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
				
				if File.file?(file)
					puts_white 'Already existed:'
				else
					# Create file.
					File.open( file.expand_path, 'w') do |file_io|
						file_io.puts content
					end
					puts_white 'Created:'
				end
				
				puts_white file
				
			end

		end # === steps
	end # === describe

end # === Views

