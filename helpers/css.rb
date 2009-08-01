configure do
  require 'sass'
  require 'compass'
  require 'ninesixty'
end # === configure

get( "/skins/:skin/css/:file.css" ) do |raw_skin, raw_file|
    
    response['Content-Type'] = 'text/css'
    
    skin_name = ( raw_skin =~ /([a-zA-Z0-9\_\-]{2,})/ && $1)
    file      = ( raw_file =~ /([a-zA-Z0-9\_\-]{2,})/ && $1 )
    
    sass_dir      = File.join( options.views, 'skins', skin_name, 'sass' )
    sass_template = Pow( sass_dir , file + '.sass')

    raise( "CSS file not found: #{request.path_info}" ) if !sass_template.file?
        
    ::Sass::Engine.new( 
        sass_template.read, 
        :load_paths=> [ sass_dir ] + Compass.sass_engine_options[:load_paths] 
    ).render 
   
end # === get


