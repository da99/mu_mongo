namespace :views do


  desc 'Uses name= and lang='
	task :create do
		
    lang      = ENV['lang'] || 'English'
    name      = assert_not_empty( ENV['name'] )
    
    assert_match( /\A[a-zA-Z\-\_0-9]+\Z/, name )

    ldir      = assert_dir_exists("templates/#{lang}")
    dir       = File.join( ldir, 'mab' )
    mab       = File.join( ldir, 'mab',   name + '.rb'   )
    sass      = File.join( ldir, 'sass',  name + '.sass' )
    view      = File.join( 'views', name + '.rb'   )
    created   = []
    already   = []

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

class #{name} < Base_View

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
			  full_path = File.expand_path(file)
				if File.exists?(full_path)
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

	end # === describe

end # === Views

