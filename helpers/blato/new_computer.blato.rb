class NewComputer
  include Blato
  bla  :start, "Prints out info. and checks installed gems. Safe to run multiple times."  do
    shout %~ 
             Make sure Postgresql is installed. 
             Then install: \nsudo apt-get install postgresql-server-dev-8.x. 
             Replace 'x' with the latest Postgresql version you are using. 
             If it still does not work: try using the 'postgres' gem instead. 
             More info: http://rubyforge.org/projects/ruby-pg 
          ~ 
    shout %~ 
            Always show hidden files: 
            http://www.watchingthenet.com/always-show-hidden-files-in-ubuntu-nautilus-file-browser.html
            Alt+F2 > gconf-editor > "desktop / gnome / file_views"
    ~, :white
    shout "Installing gems using rake task: gem:install"
    Rake::Task['gem:install'].invoke
    
    irb_rc = Pow("~/.irbrc")
    irb_rc_read = %~
      begin
        require 'rubygems'
        require 'wirble'

        # start wirble (with color)
        Wirble.init
        Wirble.colorize
      rescue LoadError => err
        warn "Couldn't load Wirble: #{err}"
      end
    ~
    if irb_rc.exists? && irb_rc.read.strip != irb_rc_read.strip
      shout :red, "DELETE file:", " #{irb_rc}"
    else
      shout `gem install wirble`
      irb_rc.create { |f| 
        f.puts irb_rc_read
      }
    end
  end

end
