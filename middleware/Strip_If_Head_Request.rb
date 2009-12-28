
class Strip_If_Head_Request

  def initialize the_app
    @app = the_app
  end

  def call the_env
    return( @app.call the_env ) unless the_env['REQUEST_METHOD'] === 'HEAD'
    
    status, headers, body = @app.call(the_env)
    
    # From The Sinatra Framework:
    #   Never produce a body on HEAD requests. Do retain the Content-Length
    #   unless it's "0", in which case we assume it was calculated erroneously
    #   for a manual HEAD response and remove it entirely.
    
    body = []
    header.delete('Content-Length') if header['Content-Length'] == '0'

    [ status, headers, body ]
  end

end
