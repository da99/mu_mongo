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

before {
            
    # Chop off trailing slash.
    if request.get? && request.path_info.size > 2 && request.path_info[ request.path_info.size - 1 , 1] == '/' 
        redirect( request.path_info.sub(/\/$/, '' ) , 301 ) # Permanent redirect.
    end         
               
    # url must not be blank
    raise( ArgumentError, "POSSIBLE SECURITY ISSUES: URL is blank." ) if options.test? && request.env['REQUEST_URI'].to_s.strip.length.zero? 
    
} # === before  

# ===============================================
# Filters
# ===============================================


# ===============================================
# Helpers
# ===============================================
require_these 'helpers/sinatra'


# ===============================================
# Require the actions.
# ===============================================
#require_these 'actions'
require Pow('actions/css')
require Pow('actions/member')


class MegaUniMain < Sinatra::Base

  use Rack::Session::Pool
  use Rack::ShowExceptions

  set :root, Pow().to_s
  set :views, Pow('views').to_s
  set :logging, true
  set :clean_trace, true
  set :raise_errors, true
  set :site_title     , 'MegaUni'
  set :site_tag_line  , 'A marketplace of predictions.'
  set :site_keywords  , 'predict the future'
  set :site_domain    , 'megauni.com'
  set :site_url       , "http://www.#{self.site_domain}/"
  set :site_support_email ,  "helpme@#{self.site_domain}"
  set :cache_the_templates, !development?

  configure do

    # Special sanitization library for both Models and Sinatra Helpers.
    #require Pow!( 'helpers/wash' )
    
    # === Set the environment.
    

    # === Include models.
    require Pow!('models/init')
    require_these 'models'

  end # === configure  

  register Sinatra::ClubManager
  register Sinatra::RenderMab
  # register Sinatra::SSController
  register Sinatra::FlashIt
  
  
  get( '/' ) {
     someth
    describe :main, :show, :STRANGER
    render_mab
  }
  
  get( '/reset' ) {
      describe( :reset_everything, '/reset', :STRANGER) 
      TemplateCache.reset
      CSSCache.reset
      redirect( env['HTTP_REFERER'] || '/' )
  }

  get('/timer/') {
    describe_action :egg, :redirect_to_timer_slash, :STRANGER
    redirect( '/timer' )
  }
  
  get('/timer') {
    describe_action :egg, :show, :STRANGER
    Pow("public/eggs/index.html").read
  }

  
  # register Sinatra::MemberActions
  # register Sinatra::CSSActions
  
end # === class MegaUni

# MegaUniMain.run! if Pow!.to_s['home/da01'] 

