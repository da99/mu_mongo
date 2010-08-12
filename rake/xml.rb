

namespace :xml do

  task :compile do
    require 'middleware/Xml_In_Disguise'
    Xml_In_Disguise.compile.each do | xml_file, (html_file, content) |
    File.open(html_file, 'w') { |file|
      file.puts content
    }
    end
  end

  task :cleanup do
    Dir.glob('templates/*/mustache/*.xml').each { |file|
      File.delete file
    }
  end

end # namespace :mab
