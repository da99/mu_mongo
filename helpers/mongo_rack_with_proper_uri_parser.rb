
class Rack::Session::Mongo

  def init_w_proper_uri app, opts
    if opts[:server] && opts[:server]['mongodb://']
      orig = opts[:server]
      opts[:server] = orig.split('@').last 
      init_w_poor_uri(app, opts)
      @connection = Mongo::Connection.from_uri(orig)
    else
      init_w_poor_uri(app, opts)
    end
  end

  alias_method :init_w_poor_uri, :initialize
  alias_method :initialize, :init_w_proper_uri 

end # === class
