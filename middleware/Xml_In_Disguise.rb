require 'builder'

class Xml_In_Disguise
  
  def initialize new_app
    @app = new_app
  end
  
  def call new_env
    if The_Bunny_Farm.production?
      raise("Can't be used in this environment: #{ENV['RACK_ENV']}") 
    end
    
    @app.call(new_env)
  end
  
  def self.xml_to_mustache lang, template_name
		
    file_basename = template_name.to_s
    
    xml_dir       = File.join('templates', lang, 'xml')
    xml_file      = File.join(xml_dir, file_basename.to_s + '.rb')
    layout_file   = File.join(xml_dir, 'layout.rb')
    
    mus_dir       = File.join('templates', lang, 'mustache')
    mus_file      = File.join(mus_dir, file_basename.to_s + '.xml')
      
    content = File.read(xml_file)

		str = ''
    compiled = Builder::XmlMarkup.new :target=> str 
		
		compiled.instance_eval content, xml_file, 1

    compiled.target!
		
  end

end # === Mab_In_Disguise
