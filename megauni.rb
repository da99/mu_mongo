$KCODE = 'UTF8'

# Ramaze::Global.content_type = 'text/html; charset=utf-8'
# Ramaze::Global.accept_charset = 'utf-8'
#header("Cache-Control: no-cache");
#header("Pragma: no-cache");

# ===============================================
# Important Gems
# ===============================================

require 'rubygems'
require 'sinatra'
require File.expand_path('./helpers/pow')
require 'sequel' 
require 'sequel/extensions/inflector'
require Pow('helpers/issue_client')

def require_these( dir );
    Pow( dir.strip ).grep(/\.rb$/).each { |f| require f.to_s.sub(/.\rb$/, '') }
end

module Kernel
    private
       def __previous_method_name__
         caller[1] =~ /`([^']*)'/ && $1.to_sym
       end
       
       def __previous_line__
        caller[1].sub(File.dirname(File.expand_path('.')), '')
       end
       
       def at_least_something?( unknown )
       
        return false if !unknown
       
        if unknown.respond_to?(:strip)
          stripped = unknown.strip
          return stripped if !stripped.empty?
        elsif unknown.is_a?(Numeric)
          return unknown if unknown > 0 
        else
          unknown
        end
        
        false
       end
end


# ===============================================
# Configurations
# ===============================================
use Rack::Session::Pool


configure do

  set :session, true

  set :site_title     , 'Mega Uni'

  set :site_tag_line  , 'The website that predicts the future.'
  set :site_keywords  , 'predict, predictions, future'
  set :site_domain    , 'megaUni.com'
  set :site_url       , Proc.new { "http://www.#{options.site_domain}/" }
  set :site_support_email , Proc.new { "helpme@#{options.site_domain}" }
  set :cache_the_templates, Proc.new { !development? }

  # Special sanitization library for both Models and Sinatra Helpers.
  require Pow!( 'helpers/wash' )

end # === configure 


configure :development do
  require Pow('~/.megauni') 
  require Pow('helpers/css')
  enable :clean_trace  

end


configure(:production) do
  # === Error handling.
  #require Pow('helpers/public_500')
  #enable :raise_errors
  #enable :show_exceptions  
  #use Rack::Public500
  DB = Sequel.connect ENV['DATABASE_URL']

end


configure :test do
  require Pow('~/.megauni') 
end

configure do
  # === Include models.
  require Pow!('helpers/model_init')    
end

# ===============================================
# Filters
# ===============================================
before {
    
    require_ssl! if request.cookies["logged_in"] || request.post?
    
    moving_date = Time.utc(2009, 8, 31, 0, 1, 1).to_i # Aug. 31, 2009
    right_now = Time.now.utc.to_i
    
    if request.host =~ /busynoise/i && request.path_info == '/'
      redirect('/egg')
    end
    
    [:busynoise, :myeggtimer].each { |name|
      if request.host =~ /#{name}/i && ['/', '/egg', '/eggs'].include?(request.path_info)
        halt show_old_site( name, moving_date < right_now )
      end
    }

    # If .html file does not exist, try chopping off .html.
    if request.path_info =~ /\.html?$/ && !Pow('public', request.path_info).file?
      redirect( request.path_info.sub( /\.html?$/, '') )
    end
    
    # Chop off trailing slash and use a  permanent redirect.
    if request.get? && 
        request.path_info != '/' &&
          request.path_info[ request.path_info.size - 1 , 1] == '/'
      # new_path = request.path_info
      # new_path += "?#{request.query_string}"if !request.query_string.empty?
      redirect( request.url.sub('/?', '/').sub(/\/$/, '' ) , 301 )  
    end 
               
    # url must not be blank. Sometimes I get error reports where the  URL is blank.
    # I have no idea how that is even possible, so I put this:
    if production? && 
      ( env['REQUEST_URI'].to_s.strip.empty? || 
          request.path_info.to_s.strip.empty? )
      raise( ArgumentError, "POSSIBLE SECURITY ISSUES: URL is blank: #{env['REQUEST_URI'].inspect}, #{request.path_info.inspect}" ) 
    end
    
} # === before  


# ===============================================
# Helpers
# ===============================================
require_these 'helpers/sinatra'

error {
  if production?
    IssueClient.create(env, options.environment, env['sinatra.error'] )
  end
  "Programmer error found. I will look into it."
}

not_found {

  if production?
    IssueClient.create(env, options.environment, "404 - Not Found", 'Referer: '+ env['HTTP_REFERER'].to_s )
  end
  
  if request.xhr?
    '<div class="error">Action not found.</div>'
  else
    file_404 = Pow('public/404.html')
    content_404 = file_404.file? ? 
                    file_404.read :
                    "Not found"
  end
  
}


helpers {

  def show_old_site(name, show_moving = false)
  
    page_name = show_moving ? 'moving' : 'index'
  
    site_name = case name
      when :busynoise, :busy_noise
        'busy-noise'
      when :myeggtimer, :my_egg_timer
        'my-egg-timer'
      else
        not_found
    end
    
    Pow("public/#{site_name}/#{page_name}.html").read
    
  end # === show_old_site
}
# ===============================================
# Require the actions.
# ===============================================
require_these 'actions'


get( '/' ) {
  describe :main, :show
  render_mab
}


get '/help' do
  describe :main, :help
  render_mab
end

get( '/blog' ) {
  redirect('/hearts')
}

get( '/about' ) {
  redirect('/help')
}


get '/salud' do
  describe :main, :salud
  render_mab :layout=>nil
end


get( '/reset' ) {
    TemplateCache.reset
    CSSCache.reset
    redirect( env['HTTP_REFERER'] || '/' )
}


get('/timer') {
  Pow("public/eggs/index.html").read
}

get('/eggs?') {
  show_old_site :busy_noise
}

get('/eggs-new') {
  describe :egg, :show
  render_mab
}


get('/*robots.txt') {
  redirect('/robots.txt')
}

get '/my-egg-timer' do
  show_old_site :my_egg_timer
end

get '/busy-noise' do
  show_old_site :busy_noise
end

get '/*beeping.*' do
  exts = ['mp3', 'wav'].detect  { |e| e == params['splat'].last.downcase }
  not_found if !exts
  redirect "http://megauni.s3.amazonaws.com/beeping.#{exts}" 
end



