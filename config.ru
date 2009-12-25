
begin

  require 'middleware/allow_only_roman_uri'
  require 'middleware/squeeze_uri_dots' 
	require 'middleware/find_the_bunny'
  require 'middleware/Always_Find_Favicon'

  require 'megauni'
  require 'mustache'

  my_app_root     = File.expand_path( File.dirname(__FILE__) )
  down_time_file  = File.join( my_app_root, '/helpers/sinatra/maintain')
  issue_client    = File.join( my_app_root, '/helpers/app/issue_client') 
  
  # ===============================================
  # Configurations
  # ===============================================


	# === Protective
  use Allow_Only_Roman_Uri
	use Squeeze_Uri_Dots
	
	# === Modifiers
	use Rack::ContentLength

	# === Content Generators
  use Always_Find_Favicon
  use Rack::Static, :root=> 'public', :urls => ["/images", "/favicon.ico", '/apple-touch-icon.png']
  
  if The_Bunny_Farm.non_production?
		require 'middleware/render_css' 
		use Render_Css
  end

	# === Helpers
  use Rack::Session::Pool
	use Find_The_Bunny

  if The_Bunny_Farm.non_production?
    require( 'middleware/mab_in_disguise'  )
    use Mab_In_Disguise
  end



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
    
  # Design_Doc.create_or_update if Design_Doc.needs_push_to_db?
    
  # Finally, start the app.
  run The_Bunny_Farm

rescue Object => e
  
  # require issue_client
  # 
  # IssueClient.create( 
  #  {'PATH_INFO' => __FILE__.to_s, 'HTTP_USER_AGENT' => 'Rack', 'REMOTE_ADDR'=>'127.0.0.1' },
  #  ENV['RACK_ENV'], 
  #  $!
  # ) 
	if ENV['RACK_ENV'] == 'development'
		raise e
	end
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




