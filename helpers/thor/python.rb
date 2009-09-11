class Python < Thor

  
	desc :webpy, "Runs web.py after compiling templates. Uses :exec"
  def webpy
		invoke 'faml:compile'
		invoke :pyc_sweep
		invoke 'sass:compile'
		exec "python #{File.basename(Pow().to_s)}.py 4567"
	end

	desc :sweep, "Delete all .pyc in directories and sub-directories."
  def sweep
		Dir['**/*.pyc'].each do |f|
			File.delete(f) 
		end
	end

end
