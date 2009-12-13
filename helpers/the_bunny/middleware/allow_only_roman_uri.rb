class Allow_Only_Roman_Uri
  
  def initialize new_app
    @app = new_app
  end
  
  def call new_env
    if new_env['PATH_INFO'][/[^a-zA-Z0-9\_\-\/\.]+/]
      content = "<h1>Not Found</h1>"
      [404, {'Content-Type' => 'text/html', 'Content-Type' => content.size.to_s }, content]
    else
      @app.call new_env
    end
  end
  
end # === Allow_Only_Roman_Uri
