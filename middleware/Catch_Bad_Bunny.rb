
class Catch_Bad_Bunny

  def initialize the_app
    @app = the_app
  end

  def call the_env
    begin
      begin
        begin
          @app.call the_env
        rescue The_App::Redirect
          the_env['bunny.app'].response.finish
        end
      rescue The_App::HTTP_404
        the_env['bad.bunny'] = $!
        response             = the_env['bunny.app'].response
        response.status      = 404
        response.body        = (the_env['bunny.404'] || "<h1>Not Found</h1><p>#{the_env['PATH_INFO']}</p>" )
        response.finish
      end
    rescue Object => e

      if The_App.development?
        raise $!
      end
      
      the_env['bad.bunny'] = $!
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

end # === 
