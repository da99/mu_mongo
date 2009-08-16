
module Rack
  # Rack::ShowExceptions catches all exceptions raised from the app it
  # wraps.  It shows a useful backtrace with the sourcefile and
  # clickable context, the whole Rack environment and the request
  # data.
  #
  # Be careful when you use this on public-facing sites as it could
  # reveal information helpful to attackers.

  class Public500
    CONTEXT = 7

    def initialize(app)
      @app = app

    end

    def call(env)
      @app.call(env)
    rescue StandardError, LoadError, SyntaxError => e
      msg = "Error found. Come back later."
      [500,
       {"Content-Type" => "text/html",
        "Content-Length" => msg.size },
        msg]
    end

  end
end
