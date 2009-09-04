# ====================================================================================
# ====================================================================================
class Run

  include Blato

  # These use 'exec', which replaces the current process (i.e. Rake)
  # More info: http://blog.jayfields.com/2006/06/ruby-kernel-system-exec-and-x.html
  bla :light, "Runs the lighttpd server. (Uses :exec to replace current process.)" do
    exec "sudo /etc/init.d/lighttpd start"
  end

  bla :dev, "Runs Thin server in :development mode. (Uses :exec.)" do
    invoke 'sass:delete'
    exec  "thin start --rackup config.ru -p 4567"
  end
  
  bla :test, "Runs Thin in :test mode. (Uses :exec.)" do
    invoke 'sass:compile'
    exec 'DATABASE_URL=postgres://da01:xd19yzxkrp10@localhost/newsprint-db-test'
  end

	bla :webpy, "Runs web.py after compiling templates. Uses :exec" do
		invoke 'faml:compile'
		invoke 'run:pyc_sweep'
		invoke 'sass:compile'
		exec "python #{File.basename(Pow().to_s)}.py 4567"
	end

	bla :pyc_sweep, "Delete all .pyc in directories and sub-directories." do
		Dir['**/*.pyc'].each do |f|
			Pow(f).delete 
		end
	end

end # === namespace
