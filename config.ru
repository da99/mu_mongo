

my_app_root     = File.expand_path( File.dirname(__FILE__) )
maintain_page_1 = my_app_root + '/helpers/sinatra/maintain'
maintain_page_2 = my_app_root + '/helpers/sinatra/down.maintain' 

begin # showing maintainence page if it exists.

  require( maintain_page_1 )

rescue LoadError

  begin # the app.
  
    require( my_app_root + '/megauni' )

  rescue # error in the app.

    begin
      raise if Sinatra::Application.environment.to_sym === :development

      $KCODE = 'UTF8'
      require 'rubygems'
      require 'sinatra'

      # Show maintenance message.
      begin
        require( maintain_page_1  )
      rescue LoadError
        require( maintain_page_2 )
      end

      # Log error.
      require( my_app_root + '/helpers/app/issue_client' )
      IssueClient.create( 
          {'PATH_INFO' => __FILE__.to_s, 'HTTP_USER_AGENT' => 'Rack', 'REMOTE_ADDR'=>'127.0.0.1' },
          Sinatra::Application.environment, 
          $!
      )

    rescue
      before {
        halt "Error occurred. Come back later."
      }
    end

  end
end

# Finally, start the app.
run Sinatra::Application
