

get '/news/new/' do 

  require_log_in!(:ADMIN)
  describe :news, :new

  render_mab

end # === get
