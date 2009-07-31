

configure do
  require 'sass'
  SKINS_DIR              = Pow( Sinatra::Application.views, 'skins')
  SASS_FRAMEWORKS        = Pow( Sinatra::Application.views, 'sass_frameworks' )
  FRAMEWORK_960          = SASS_FRAMEWORKS / "960"
  FRAMEWORK_COMPASS      = SASS_FRAMEWORKS / "compass/stylesheets"
  
  class CSSCache

    def self.add( raw_index, value )
      @cache ||= {}
      @cache[raw_index.to_s] = value
    end
    
    def self.get( raw_index )
      return nil if !@cache
      @cache[raw_index.to_s]
    end
    
    def self.reset
      @cache = {}
    end

  end 
   
end # === configure

 

get( "/css/:skin/:file.css" ) do |raw_skin, raw_file|
    
    response['Content-Type'] = 'text/css'
    
    skin_name = ( raw_skin =~ /([a-zA-Z0-9\_\-]{2,})/ && $1)
    file      = ( raw_file =~ /([a-zA-Z0-9\_\-]{2,})/ && $1 )
    
    css_dir       = SKINS_DIR / skin_name / 'css'
    sass_template = css_dir / ( file + '.sass')

    cache_template = CSSCache.get(sass_template)
    if cache_template
      cache_template 
    else
      
      raise( "CSS file not found: #{request.path_info}" ) if !sass_template.file?
          
      css_content = ::Sass::Engine.new( 
          sass_template.read, 
          :load_paths=>[ css_dir, FRAMEWORK_960,  FRAMEWORK_COMPASS ]
      ).render 
      
      self.options.cache_the_templates ?
        CSSCache.add( sass_template , css_content ) :
        css_content ;

    end
   
end # === get


