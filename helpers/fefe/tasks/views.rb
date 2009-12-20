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

			if File.file?(mab)
				already << mab
			else
				# Create Markaby file.
				File.open(mab, 'w') do |file|
					file.puts %~
# #{view}
# #{name}

partial('__nav_bar')

div.content! { 
}
					~.lstrip
				end
				created << mab
			end

			if File.file?(view)
				already << view
			else
				# Create :view file.
				File.open(view, 'w') do |file|
					file.puts %~
# #{mab}

class #{name} < Bunny_Mustache

  def title 
    '...'
  end
	
end # === #{name}
					~.lstrip
				end
				created << view
			end

			if not already.empty?
				puts_white 'Already existed:'
				already.each { |file|
					puts_white file
				}
			end

			if not created.empty?
				puts_white 'Created:'
				already.each { |file|
					puts_white file
				}
			end

		end
	end

end # === Views

