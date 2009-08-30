class NewComputer
  
  include Blato


  bla  :start, "Prints out info. and checks installed gems. Safe to run multiple times."  do
        
    shout "Firefox: browser.history_expire_days.mirror && browser.history_expire_days to 3: http://blogs.n1zyy.com/n1zyy/2008/09/16/firefoxs-history-setting/", :white
    shout "Firefox: browser.history_expire_sites to '400'", :white
    
    shout %~ 
             Make sure Postgresql is installed. 
             Then install: \nsudo apt-get install postgresql-server-dev-8.x. 
             Replace 'x' with the latest Postgresql version you are using. 
             If it still does not work: try using the 'postgres' gem instead. 
             More info: http://rubyforge.org/projects/ruby-pg 
          ~ if !capture('psql --version')['psql (PostgreSQL) 8']

    shout %~ 
            Always show hidden files in  Nautilus: 
            http://www.watchingthenet.com/always-show-hidden-files-in-ubuntu-nautilus-file-browser.html
            Alt+F2 > gconf-editor > "desktop / gnome / file_views"
    ~, :white
    

    
    if !capture('which blato')['bin/blato']
      shout "Symlink blato to a path dir."
    elsif !capture('crontab -l')['bin/blato bzr:my_life_dev_check']
      shout "Setup CRONT:", :white
      shout "crontab -e", :white
      shout "18 * * * * #{capture('which blato')} bzr:quiet_my_life_dev_check", :white 
    end
    
    install_bzr

    install_git 

    install_vim

    install_irb

    install_light_conf

    install_gemrc

  end # === bla :start

  def install_git
    do_install = !capture('git --version')[/git version \d/]
    if do_install
        shout "Install git with PPA "
    else
        shout capture('git config --global user.name %s' % MY_NAME.inspect) 
        shout capture('git config --global user.email %s' % MY_EMAIL)
    end
  end

  def install_bzr
    do_install = !capture('bzr --version')[ /Bazaar \(bzr\) \d/ ]
    if do_install
        shout "Install bzr: https://launchpad.net/~bzr/+archive/ppa", :white
    else
        shout capture('bzr whoami "%s <%s>"' % [MY_NAME, MY_EMAIL])
    end
  end


  def install_vim
    shout "Installing VIM settings.", :white
    vim_bk = Pow('~/.vim-tmp')
    if !vim_bk.exists?
        shout "Creating #{vim_bk}", :yellow
        shout capture("mkdir %s" % vim_bk.to_s), :white
    end

    vimrc = (MY_PREFS / 'vim/vimrc.vim')
    new_vim_rc = Pow('~/.vimrc')
    if !new_vim_rc.exists?
        shout(capture('ln -s %s %s' % [vimrc.to_s.inspect, new_vim_rc.to_s.inspect] ))
    end

    bash_file = Pow(File.expand_path('~/.bashrc')).read
    if !bash_file['gvim --remote-tab-silent']
        shout('Put alias gvim="gvim --remote-tab-silent" at the end of your ~/.bashrc file.')
    end
    
    shout( "Install vividchalk in ~/.vim/colors", :white ) if !Pow('~/.vim/colors/vividchalk.vim').exists?

  end

  def install_irb
    
    home_irb = Pow(File.expand_path("~/.irbrc"))
    irb = (MY_PREFS / 'ruby' / 'irbrc.rb')
    
    both_exist = home_irb.exists? && irb.exists?
    both_match = both_exist && (home_irb.read.strip == irb.read.strip) &&  File.symlink?(home_irb.to_s)

    
    install_irb = !both_exist && irb.exists?

    if both_exist && !both_match 
        shout "DELETE file: #{home_irb}"
    end
    
    if install_irb
        shout `gem install wirble` if !capture('gem list')['wirble']
        shout(capture("ln -s %s %s" % [irb.to_s.inspect, home_irb.to_s.inspect]))
    end
  end

  def install_gemrc
    gem_rc_yaml = (MY_PREFS / 'ruby' / 'gemrc.yaml')
    gem_rc = Pow('~/.gemrc')
    both_exists = gem_rc_yaml.exists? && gem_rc.exists?
    both_match = both_exists && gem_rc_yaml.read.strip == gem_rc.read.strip && File.symlink?(gem_rc.to_s)
    do_link = gem_rc_yaml.exists? && !both_exists 

    if do_link
        shout capture('ln -s %s %s' % [gem_rc_yaml.to_s.inspect,  gem_rc.to_s.inspect] )
    else
        shout "#{gem_rc_yaml} not found." if !gem_rc_yaml.exists?
        shout "#{gem_rc} must be deleted." if both_exists && !both_match 
    end
    shout "Installing gems using task: gems:update", :yellow
    shout capture_task('gems:update'), :white
  end

  def install_light_conf

    light_conf = (MY_PREFS / 'light.conf')
    sudo_light_conf = Pow("/etc/lighttpd/lighttpd.conf")

    if !light_conf.exists?
        shout "File not found: #{light_conf}"      
    end
    
    both_exist = light_conf.exists? && sudo_light_conf.exists?
    both_match = both_exist && ( light_conf.read.strip != sudo_light_conf.read.strip )

    if both_exist && !both_match
        shout( "Sudo copy file to #{sudo_light_conf}" ) 
    end
    
  end



end # === class NewComputer
