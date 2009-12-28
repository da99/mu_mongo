
begin

	%w{
		Allow_Only_Roman_Uri
		Squeeze_Uri_Dots 
		Find_The_Bunny
		Always_Find_Favicon
		Slashify_Path_Ending
		Serve_Public_Folder
		Redirect_Mobile
		Catch_Bad_Bunny
    Strip_If_Head_Request
	}.each { |middle|
		require "middleware/#{middle}"
	}

  require 'megauni'
  
  Design_Doc.create_or_update if Design_Doc.needs_push_to_db?
  
  my_app_root     = File.expand_path( File.dirname(__FILE__) )
  down_time_file  = File.join( my_app_root, '/helpers/sinatra/maintain')
  issue_client    = File.join( my_app_root, '/helpers/app/issue_client') 
  
  # ===============================================
  # Configurations
  # ===============================================


	# === Protective
	use Rack::ContentLength
  use Allow_Only_Roman_Uri
	use Squeeze_Uri_Dots
  use Slashify_Path_Ending
  use Redirect_Mobile
	

	# === Modifiers


	# === Content Generators
  use Always_Find_Favicon
  use Serve_Public_Folder, ['/busy-noise/', '/my-egg-timer/', '/styles/', '/skins/']
  
  if The_App.non_production?
		require 'middleware/Render_Css' 
		use Render_Css
  end

	# === Helpers
  use Rack::Session::Pool
  use Strip_If_Head_Request
  
  # === Low-level Helpers 
  # === (specifically designed for The_App).
	use Catch_Bad_Bunny
	use Find_The_Bunny


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
    
    
  # Finally, start the app.
  run The_App

rescue Object => e
  
  # require issue_client
  # 
  # IssueClient.create( 
  #  {'PATH_INFO' => __FILE__.to_s, 'HTTP_USER_AGENT' => 'Rack', 'REMOTE_ADDR'=>'127.0.0.1' },
  #  ENV['RACK_ENV'], 
  #  $!
  # ) 
	if ['test', 'development'].include?(ENV['RACK_ENV'])
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




