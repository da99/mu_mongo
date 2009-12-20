class Views

	include FeFe

	describe :create do
		
		it 'Creates a template with corresponding view file.'
		
		steps([:name, nil], [:lang, 'english']) do |name, lang|
			
			demand_regex_match( /\A[a-zA-Z\-\_0-9]+\Z/, name)
			dir  = File.join('templates', lang.downcase, 'mab')
			mab  = File.join(dir, name + '.rb').expand_path
			view = File.join('views', name + '.rb')
			created = []
			already = []

			templates = {}
			templates[mab] = %~
# #{view}
# #{name}

partial('__nav_bar')

div.content! { 
} ~.lstrip

			templates[view] = %~
# #{mab}

class #{name} < Bunny_Mustache

  def title 
    '...'
  end
	
end # === #{name} ~.lstrip

			templates.each do |file, content|
				
				if File.file?(file)
					puts_white 'Already existed:'
				else
					# Create file.
					File.open(file, 'w') do |file_io|
						file_io.puts content
					end
					puts_white 'Created:'
				end
				
				puts_white file
				
			end

		end # === steps
	end # === describe

end # === Views

