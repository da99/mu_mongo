require 'sass'

SKINS_DIR                         =  Pow( Sinatra::Application.views, 'skins')
SASS_FRAMEWORKS        = Pow( Sinatra::Application.views, 'sass_frameworks' )
FRAMEWORK_960            = SASS_FRAMEWORKS / "960"
FRAMEWORK_COMPASS = SASS_FRAMEWORKS / "compass/stylesheets"

get( "/css/:skin/:file.css" ) do |raw_skin, raw_file|
    
    skin_name =  ( raw_skin =~ /([a-zA-Z0-9\_\-]{2,})/ && $1)
    file   = ( raw_file =~ /([a-zA-Z0-9\_\-]{2,})/ && $1 )
    
    css_dir       = SKINS_DIR / skin_name / 'css'
    sass_template = css_dir / ( file + '.sass')

    cache_template = CSSCache.get(sass_template)
    if cache_template
      response['Content-Type'] = 'text/css'
      return cache_template 
    end
    
    if !sass_template.file?
        raise "CSS file not found: #{request.path_info}"
    end
    
    response['Content-Type'] = 'text/css' 
    
    css_content = Sass::Engine.new( 
        sass_template.read, 
        :load_paths=>[ css_dir, FRAMEWORK_960,  FRAMEWORK_COMPASS ]
    ).render 
    
    CSSCache.add( sass_template , css_content )
   
end # === get


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

__END__
# ======================================================================
# === Let's try and use the 960 plugin for Compass... without using Compass.
# NOTE: Gem load paths point to a /lib dir in the Gem dir. That is why we need
# '..'
# COMPASS_PLUGIN_960 = Pow( Gem.latest_load_paths.grep( /compass\-960/ ).first ) / '..'
# SASS_960_DIR       = COMPASS_PLUGIN_960  / 'sass/960'
# COMPASS_DIR        = Pow( Gem.latest_load_paths.grep( /chriseppstein\-compass\-[0-9\.]{2,}\/lib/ ) ) / '..'
# COMPASS_SASS_DIR   = COMPASS_DIR / 'frameworks/compass/stylesheets'
# require COMPASS_PLUGIN_960  / 'lib/ninesixty/sass_extensions.rb'

# ==== Update the above code if the file structure of chriseppstein-compass-960-plugin-changes.
# ==== We are done using the 960 plugin...
#      other than using SASS_960_DIR in the :load_paths for SASS, below.
# ======================================================================
