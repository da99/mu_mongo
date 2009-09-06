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
require 'sequel' 
require 'sequel/extensions/inflector'
require File.expand_path('./helpers/kernel')
require Pow('helpers/issue_client')


# ===============================================
# Configurations
# ===============================================
use Rack::Session::Pool


configure :test do
  require Pow('~/.megauni') 
end


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


configure do

  set :session,           true

  set :site_title,        'Mega Uni'
  set :site_tag_line,     'The website that predicts the future.'
  set :site_keywords,     'predict, predictions, future'
  set :site_domain,       'megaUni.com'
  set :site_url,          Proc.new { "http://www.#{options.site_domain}/" }
  set :site_support_email,  Proc.new { "helpme@#{options.site_domain}" }
  set :cache_the_templates, Proc.new { !development? }

  # Special sanitization library for both Models and Sinatra Helpers.
  require Pow!( 'helpers/wash' )
  
  # === Include models.
  require Pow('helpers/model_init')   

end # === configure 


# ===============================================
# Helpers
# ===============================================
require_these 'helpers/sinatra', %w{
  old_apps
  flash_it
  club_manager
  render_mab
  html_props_for_models
  swiss_clock
}


# ===============================================
# Filters
# ===============================================
before {
    
    require_ssl! if request.cookies["logged_in"] || request.post?
    
    # url must not be blank. Sometimes I get error reports where the  URL is blank.
    # I have no idea how that is even possible, so I put this:
    if production? && 
      ( env['REQUEST_URI'].to_s.strip.empty? || 
          request.path_info.to_s.strip.empty? )
      raise( ArgumentError, "POSSIBLE SECURITY ISSUES: URL is blank: #{env['REQUEST_URI'].inspect}, #{request.path_info.inspect}" ) 
    end
    
} # === before  

error {
  IssueClient.create(env, options.environment, env['sinatra.error'] )
  read_if_file('public/500.html') || "Programmer error found. I will look into it."
} # === error


not_found {

  IssueClient.create(env, 
      options.environment, 
      "404 - Not Found", 
      "Referer: #{env['HTTP_REFERER']}" )
  
  if request.xhr?
    '<div class="error">Action not found.</div>'
  else
    
    # Add trailing slash and use a  permanent redirect.
    # Why a trailing slash? Many software programs 
    # look for files by appending them to the url: /salud/robots.txt
    # Without adding a slash, they will go to: /saludrobots.txt
    if request.get? && 
        request.path_info != '/' &&
          request.path_info[ request.path_info.size - 1 , 1] != '/' &&
            request.query_string.to_s.strip.empty?
      redirect( request.url + '/' , 301 )  
    end 

    read_if_file('public/404.html') || "Page not found. Try checking for any typos in the address."

  end
  
} # === not_found


# ===============================================
# Require the actions.
# ===============================================
require_these 'actions', %w{ 
  main 
  old_app
  heart 
  member 
  session 
}

