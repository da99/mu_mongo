
$KCODE = 'UTF8'
require 'jcode'

# ===============================================
# Important Gems
# ===============================================
require 'multibyte'
require 'cgi' # Don't use URI.escape because it does not escape all invalid characters.

my_app_root     = File.expand_path( File.dirname(__FILE__) )
down_time_file  = File.join( my_app_root, '/helpers/sinatra/maintain')
issue_client    = File.join( my_app_root, '/helpers/app/issue_client')

begin

  require( 'helpers/app/method_air_bags'  )
  require( 'helpers/the_bunny/farm'  )
  require( 'helpers/the_bunny/middleware/allow_only_roman_uri'  )
  require( 'helpers/the_bunny/middleware/squeeze_uri_dots'  )

  # ===============================================
  # App Helpers
  # ===============================================
  # require( 'helpers/app/require'  )
  # require_these 'helpers/app', %w{
  #   kernel
  #   chars_compat
  #   string_blank
  #   string_inflections
  #   read_if_file
  #   pow
  #   symbolize_keys
  #   json
  #   data_pouch
  #   cleaner_dsl
  #   demand_arguments_dsl
  # }
  
  
  # ===============================================
  # Configurations
  # ===============================================

	use Rack::ContentLength
  use Allow_Only_Roman_Uri
	use Squeeze_Uri_Dots
  use Rack::Session::Pool  
	
  # use( Rack::Reloader, 2 ) if The_Bunny_Farm.development?

  # Lil_Config = Struct.new(
  #   :SITE_DOMAIN, 
  #   :SITE_TITLE,
  #   :SITE_TAG_LINE
  #   :SITE_HELP_EMAIL, 
  #   :SITE_URL, 
  #   :SITE_SUPPORT_EMAIL,
  #   :VIEWS_DIR,
  #   :CouchDB_URI,
  #   :DB_NAME,  
  #   :DB_CONN,
  #   :DESIGN_DOC_ID
  # ).new


  class The_Bunny_Farm
    
    module Options
      SITE_DOMAIN        = 'megaUni.com'
      SITE_TITLE         = 'Mega Uni'
      SITE_TAG_LINE      = 'For all your different lives: friends, family, work.'
      SITE_HELP_EMAIL    = "helpme@#{SITE_DOMAIN}"
      SITE_URL           = "http://www.#{SITE_DOMAIN}/"
      SITE_SUPPORT_EMAIL = "helpme@#{SITE_DOMAIN}"
      VIEWS_DIR          = 'views/skins/jinx' # .expand_path
      DESIGN_DOC_ID      = '_design/megauni'
    end
    
  end # === class

  case ENV['RACK_ENV']
    
    when 'test'
      class The_Bunny_Farm
        module Options
          CouchDB_URI = "https://da01tv:isleparadise4vr@localhost"
          DB_NAME     = 'megauni-test'
          DB_CONN     = File.join(CouchDB_URI, DB_NAME)
        end
      end
      
    when 'development'
      # require 'helpers/sinatra/css'
      class The_Bunny_Farm
        module Options
          CouchDB_URI = "https://da01tv:isleparadise4vr@localhost"
          DB_NAME     = "megauni-dev"
          DB_CONN     = File.join( CouchDB_URI, DB_NAME )
        end
      end

    when 'production'
      class The_Bunny_Farm
        module Options
          CouchDB_URI = "http://un**:pswd**@127.0.0.1:5984/"
          DB_NAME     = 'megauni-production'
          DB_CONN     = File.join(CouchDB_URI, DB_NAME)
        end
      end


    else
      raise ArgumentError, "Unknown RACK_ENV value: #{ENV['RACK_ENV'].inspect}"

  end # === case


  # ===============================================
  # Require Models.
  # ===============================================
  # require_these 'models', %w{
  #   _couch_plastic
  #   couch_doc
  #   design_doc
  #   resty
  #   member
  #   log_in_attempt
  #   news
  # }
  
  
  # ===============================================
  # Helpers for Requests
  # ===============================================
  # require_these 'helpers/sinatra', %w{
  #   sanitize_input
  #   describe_action
  #   urls_and_ssl
  #   mobilize
  #   flasher
  #   old_apps
  #   describe_action
  #   auth_and_auth
  #   resty
  #   render_ajax_response
  #   render_mab
  #   html_props_for_models
  #   swiss_clock
  #   text_to_html
  #   red_cloth
  #   crud_dsl
  #   controller_dsl
  #   redirect_dsl
  #   wash
  # }



  # ===============================================
  # Require the actions.
  # ===============================================
  # require_these 'actions', %w{
  #   errors 
  #   main
  #   old_app
  #   member
  #   session
  #   news
  #   resty
  #   try_textile
  # }
    
  # DesignDoc.create_or_update if DesignDoc.needs_push_to_db?
    
  # Finally, start the app.
  the_app = The_Bunny_Farm
  run the_app

rescue Object => e
  
  # require issue_client
  # 
  # IssueClient.create( 
  #  {'PATH_INFO' => __FILE__.to_s, 'HTTP_USER_AGENT' => 'Rack', 'REMOTE_ADDR'=>'127.0.0.1' },
  #  ENV['RACK_ENV'], 
  #  $!
  # ) 

  the_app = lambda { |env|
    suffix = case ENV['RACK_ENV']
             when 'development'
               e.class.to_s + ': ' + e.message + "<br />#{e.backtrace.join("<br />")}"
             else
               ''
             end
    content = case env['REQUEST_METHOD']
              when 'GET'
                %~<html><body><h1>Server Error.</h1><p>Try again later.</p>#{suffix}</body></html>~
              when 'PUT', 'POST', 'DELETE'
                if @env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
                  %~<div class="error">Server Error. Try again later.</div>~
                else
                  %~<html><body><h1>Server Error.</h1><p>Try again later.</p></body></html>~
                end
              when 'HEAD'
                ''
              end
    [500, {'Content-Type' => 'text/html', 'Content-Length'=>content.size.to_s}, content]
  }
  
  run the_app
  
end # === begin




