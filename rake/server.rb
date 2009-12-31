# ====================================================================================
# ====================================================================================

class Server 
  include FeFe
  
  describe :nginx do
    it 'Starts up Nginx, after invoking nginx_stop.'
    steps {
      require 'rush'
      if Rush.processes.filter(:cmdline=>/nginx/).size > 0
        puts_red 'Shutdown nginx first.'
        exit(1)
      end
      exec 'sudo /etc/init.d/nginx start'
    }
  end

  describe :nginx_stop do
    it 'Stops Nginx.'
    steps {
      exec 'sudo /etc/init.d/nginx stop'
    }
  end

  # These use 'exec', which replaces the current process (i.e. Rake)
  # More info: http://blog.jayfields.com/2006/06/ruby-kernel-system-exec-and-x.html
  describe :light do
    it "Runs the lighttpd server. (Uses :exec to replace current process.)"
    steps {
      require 'rush'
      if Rush.processes.filter(:cmdline=>/lighttpd/).size > 0
        puts_red 'Shutdown lighttpd first.'
        exit(1)
      end
      exec "sudo /etc/init.d/lighttpd start"
    }
  end

  describe :dev do
    it "Runs Unicorn in :development mode. (Uses :exec.)"
    steps {
      fefe_run 'sass:delete'
      exec "unicorn -p 4999"
    }
  end

  describe :reload do
    it "Kill Unicorn worker, which will then be re-started."
    steps {
      puts_white 'Restarting...'
      require 'rush'
      output = Rush.processes.filter(:cmdline=>/unicorn worker/).kill
      puts_white 'Done.'
      output
    }
  end


end # === class Server

