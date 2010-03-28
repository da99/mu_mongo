
require 'helpers/app/issue_client'

class Catch_Bad_Bunny

  def initialize the_app
    @app = the_app
  end

  def call the_env
    begin
      @app.call the_env
    rescue Object => e
      IssueClient.create(the_env, ENV['RACK_ENV'], $!.message, the_env['HTTP_REFERER'], e)
      case e
        when The_App::HTTP_404
          the_env['the.app.error'] = $!
          response             = Rack::Response.new
          response.status      = 404
          response.body        = begin
                                   the_env['the.app.404'] || File.read('public/404.html')
                                 rescue Object
                                   "<h1>Not Found</h1>
                                   <p>Check spelling: #{the_env['PATH_INFO']}</p>"
                                 end
          response.finish
        else

          if The_App.development_or_test?
            raise $!
          end

          the_env['the.app.error'] = $!
          response             = Rack::Response.new
          response.status      = 500
          response.body        = begin
                                   File.read('public/500.html')
                                 rescue Object
                                 '<h1>Unknown Error.</h1>'
                                 end
          response.finish
      end
    end
  end
end # === 
