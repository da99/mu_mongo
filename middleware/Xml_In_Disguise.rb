require 'builder'
require 'middleware/Mab_In_Disguise'

class Xml_In_Disguise
  
  def self.compile_all *args
    vals = compile
    vals.each do |xml_file_name, v|
      Mab_In_Disguise.save_file( xml_file_name, v.first, v.last)
    end
  end

  def self.compile file_name = '*'
    
    vals = {}

    glob_pattern = file_name == '*' ?
                        "templates/*/xml/#{file_name}.rb" :
                        file_name
                        
    Dir.glob(glob_pattern).each { |xml_file|

      file_basename = File.basename(xml_file)
      xml_dir       = File.dirname(xml_file)
      mus_dir       = xml_dir.sub('xml/', 'mustache/')
      mus_file      = xml_file.sub('xml/', 'mustache/').sub('.rb', '.xml')
      content       = File.read(xml_file)
      str           = ''
      
      compiled      = Builder::XmlMarkup.new( :target => str )
      compiled.instance_eval content, xml_file, 1

      compiled.target!
      vals[xml_file] = [mus_file, str]
    }
    
    file_name == '*' ?
      vals :
      vals[file_name].last
    
  end

end # === Xml_In_Disguise
