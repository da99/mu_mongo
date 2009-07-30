$KCODE = 'UTF8'

# ===============================================
# Important Gems
# ===============================================

require 'rubygems'
require 'sinatra'
require 'pow'

def require_these( dir );
    Pow( dir.strip ).grep(/\.rb$/).each { |f| require f.to_s.sub(/.\rb$/, '') }
end


# ===============================================
# Configurations
# ===============================================

`reset` if Sinatra::Application.development?

use Rack::Session::Pool

set :site_title     , 'MegaUni'
set :site_tag_line  , 'A marketplace of predictions.'
set :site_keywords  , 'predict the future'
set :site_domain    , 'megauni.com'
set :site_url       , "http://www.#{Sinatra::Application.site_domain}/"
set :site_support_email ,  "helpme@#{Sinatra::Application.site_domain}"

configure do

    # Special sanitization library for both Models and Sinatra Helpers.
    #require Pow!( 'helpers/wash' )
    
    # === Set the environment.
    # require Pow!( 'secret_closet' )

    # === Include models.
    #require Pow!('models/init')
    #require_these 'models'

end # === configure


# ===============================================
# Filters
# ===============================================


# ===============================================
# Helpers
# ===============================================
# require_these 'helpers/sinatra'
require Pow('helpers/sinatra/club_manager')
require Pow('helpers/sinatra/render_mab')
require Pow('helpers/sinatra/ss_controller')
require Pow('helpers/sinatra/flash_it')

# ===============================================
# Require the actions.
# ===============================================
#require_these 'actions'
require Pow('actions/css')


controller(:Main) {
    
    get( :show, '/',  :STRANGER ) 
    
    get( :reset_everything, '/reset', :STRANGER) {
        TemplateCache.reset
        CSSCache.reset
        redirect( env['HTTP_REFERER'] || '/' )
    }
    
}


controller(:Egg) {
  get(:redirect_to_eggs_slash, '/egg/?s?', :STRANGER ) {
    redirect( '/eggs/' )
  }
  get(:show, '/eggs/', :STRANGER ) {
    Pow("public/eggs/index.html").read
  }  
}



