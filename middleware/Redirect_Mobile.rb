class Redirect_Mobile

  def initialize the_app
    @app = the_app
    @salud_urls = %w{
      /saludm
      /saludm 
      /saludmobi
      /saludiphone
      /saludpda
    }
    @url = /\/(m|mobi|mobile|iphone|pda)\/$/ 
  end

  def call env
    do_salud    = @salud_urls.detect { |url| env['PATH_INFO'].index(url) === 0 }
    do_redirect = env['PATH_INFO'].index( @url )
    if not (do_redirect || do_salud)
      return(@app.call(env))
    end

    response = Rack::Response.new
    response.set_cookie("use_mobile_version", {
      :value   => 'yes',
      :path    => '/',
      :expires => (Time.now + (60 * 60 * 24 * 365 * 10)),
    }) 
    
    if do_salud
      response.redirect '/salud/m/'
    else
      response.redirect env['PATH_INFO'].sub( @url, '/' )
    end
    response.finish
  end

end # === Redirect_Mobile
