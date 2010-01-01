


namespace :mab do

	task :compile do
		require 'middleware/Mab_In_Disguise'
		Mab_In_Disguise.compile.each do | mab_file, (html_file, content) |
			File.open(html_file, 'w') { |file|
				file.puts content
			}
		end
	end

	task :cleanup do
		Dir.glob('templates/*/mustache/*.html').each { |file|
			File.delete file
		}
	end


end # namespace :mab
