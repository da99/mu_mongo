require 'builder'

class Xml_In_Disguise
  
  def self.compile_all *args
    compile *args
  end

  def self.compile file_name = nil
		
		vals = {}

		Dir.glob(file_name || 'templates/*/xml/*.rb').each { |xml_file|

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
    
		file_name ?
			vals[file_name].last :
			vals
		
  end

end # === Mab_In_Disguise
