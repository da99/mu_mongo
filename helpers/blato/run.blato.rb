


# ====================================================================================
# ====================================================================================
class Run

  include Blato

  # These use 'exec', which replaces the current process (i.e. Rake)
  # More info: http://blog.jayfields.com/2006/06/ruby-kernel-system-exec-and-x.html
  desc :light, "Runs the lighttpd server. (Uses :exec to replace current process.)"
  def __light
    exec "sudo /etc/init.d/lighttpd start"
  end

  desc :dev, "Runs Thin server in :development mode. (Uses :exec.)"
  def __dev
    invoke 'sass:delete'
    exec  "thin start --rackup config.ru -p 4567"
  end
  
  desc :test, "Runs Thin in :test mode. (Uses :exec.)"
  def __test
    invoke 'sass:compile'
    exec 'DATABASE_URL=postgres://da01:xd19yzxkrp10@localhost/newsprint-db-test'
  end

end # === namespace
