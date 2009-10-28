# ====================================================================================
# ====================================================================================

class Server < Thor
  include Thor::Actions
  include Thor::Sandbox::CoreFuncs
  
  map '-n' => :nginx
  desc 'nginx', 'Starts up Nginx, after invoking nginx_stop.'
  def nginx
    if capture_all('ps aux | grep nginx')['nginx:']
      return(whisper('Shutdown nginx first with: thor server:nginx_stop'))
    end
    exec 'sudo /etc/init.d/nginx start'
  end

  desc 'nginx_stop', 'Stops Nginx.'
  def nginx_stop
    exec 'sudo /etc/init.d/nginx stop'
  end

  map '-s' => :shotgun
  desc 'shotgun', "Runs Shotgun with Thin in development mode."
  def shotgun
    invoke 'sass:delete'
    exec 'shotgun --server=thin --port=4567 config.ru'
  end

	map '-d' => :dev
  desc 'dev', "Runs Unicorn in :development mode. (Uses :exec.)"
  def dev
    invoke 'sass:delete'
    # exec  "thin start --rackup config.ru -p 4567"
    exec "unicorn -p 4567"
  end

  # These use 'exec', which replaces the current process (i.e. Rake)
  # More info: http://blog.jayfields.com/2006/06/ruby-kernel-system-exec-and-x.html
  desc :light, "Runs the lighttpd server. (Uses :exec to replace current process.)"
  def light
    exec "sudo /etc/init.d/lighttpd start"
  end

  desc :dev, "Runs Thin server in :development mode. (Uses :exec.)"
  def dev
    invoke 'sass:delete'
    exec  "thin start --rackup config.ru -p 4567"
  end

  desc :test, "Runs Thin in :test mode. (Uses :exec.)"
  def test
    invoke 'sass:compile'
    exec 'DATABASE_URL=postgres://da01:xd19yzxkrp10@localhost/newsprint-db-test'
  end


end # === class Server

