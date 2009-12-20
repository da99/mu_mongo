class Views

	include FeFe

	describe :create do
		it 'Creates a template with corresponding view file.'
		steps([:name, nil], [:lang, 'english']) do |name, lang|
			demand_regex_match( /\A[a-zA-Z\-\_0-9]+\Z/, name)
			dir  = File.join('templates', lang.downcase, 'mab')
			mab  = File.join(dir, name + '.rb').expand_path
			view = File.join('views', name + '.rb')
			if !File.file?(mab)
				# Create Markaby file.
				File.open(mab, 'w') do |file|
					file.puts %~
# #{view}
# #{name}

partial('__nav_bar')

div.content! { 
}
					~
				end
			end

			if !File.file?(view)
				# Create :view file.
				File.open(view, 'w') do |file|
					file.puts %~
# #{mab}

class #{name} < Bunny_Mustache

  def title 
    '...'
  end
	
end # === #{name}
					~
				end
			end
		end
	end

end # === Views

