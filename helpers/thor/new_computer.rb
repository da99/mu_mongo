class NewComputer < Thor

  include Thor::Sandbox::CoreFuncs

  desc  :start, "Prints out info. and checks installed gems. Safe to run multiple times."
  def start
    
    shout "Install: http://ubuntuforums.org/showthread.php?t=1130582&highlight=flash+problem"
    shout %~
        Make sure Postgresql is installed.
        Then install:
          sudo apt-get install postgresql-server-dev-8.x.
        Replace 'x' with the latest Postgresql version you are using.
        If it still does not work: try using the 'postgres' gem instead.
        More info: http://rubyforge.org/projects/ruby-pg
    ~ if !capture_all('psql --version')[/psql \(PostgreSQL\) \d/]

    gconf = Pow(File.expand_path('~/.gconf/desktop/gnome/file_views/%gconf.xml'))
    shout %~
        Always show hidden files in  Nautilus:
        http://www.watchingthenet.com/always-show-hidden-files-in-ubuntu-nautilus-file-browser.html
        Alt+F2 > gconf-editor > "desktop / gnome / file_views"
    ~ if !gconf.exists? || !gconf.read['show_hidden_files']

    cron_task ="cd /home/da01/megauni && #{capture_all('which thor')} bzr:my_life_dev_check"
    if !capture_all('crontab -l')[cron_task]
      whisper "Setup CRONT:"
      whisper "crontab -e"
      whisper "59 */3 * * * #{cron_task}"
    end

    install_dropbox 

    install_firefox

    install_bzr

    install_git

    install_vim

    install_irb

    install_light_conf

    install_gemrc

    install_open_with_gvim_tabs

  end # === desc :start

  private # ==================================================================

  def install_dropbox
    dropbox_path = capture_all('which dropbox')
    if dropbox_path.empty?
      shout "Install DropBox"
    end

    dropbox_dir = Pow('~/Dropbox')
    if !dropbox_dir.exists?
      results = capture_all('mkdir %s', dropbox_dir)
      shout "Error in creating #{dropbox_dir}: #{results}"
      return nil
    end

    if !dropbox_dir.directory?
      shout "This needs to be a directory: #{dropbox_dir}"
      return nil
    end

    dir_objs = capture_all('cd %s && ls', dropbox_dir).split("\n")
    if dir_objs.size > 1
      shout "Too many things in #{dropbox_dir}. Only one must exist."
      return nil
    end

    if dir_objs.size == 0
      make_symlink_or_raise(BZR_DIR, BACKUP_DIR)
    end

    if dir_objs.first != File.basename(BACKUP_DIR)
      shout "Unknown object in backup directory: #{dir_objs.first}"
      return nil
    end

  end

  def install_git
    do_install = !capture_all('git --version')[/git version \d/]
    if do_install
        shout "Install git with PPA "
    else
        shout capture_all('git config --global user.name %s' % MY_NAME.inspect)
        shout capture_all('git config --global user.email %s' % MY_EMAIL)
    end
  end

  def install_bzr
    do_install = !capture_all('bzr --version')[ /Bazaar \(bzr\) \d/ ]
    if do_install
        whisper "Install bzr: https://launchpad.net/~bzr/+archive/ppa"
    else
        shout capture_all('bzr whoami "%s <%s>"' % [MY_NAME, MY_EMAIL])
    end
  end

  def install_firefox
    vals = {}
    # http://blogs.n1zyy.com/n1zyy/2008/09/16/firefoxs-history-setting/
    vals[:"browser.history_expire_days.mirror"] = 3
    vals[:"browser.history_expire_days"] = 3
    vals[:"browser.history_expire_sites"] = 400
    grep_vals = capture_all("grep history -r ~/.mozilla/firefox --include=prefs.js")

    vals.each do |k,v|
        shout "Change Firefox: #{k} ===>> #{v}" if !grep_vals[/#{k}...#{v}/]
    end

    plugins = [ "Adblock Plus",
        "Firebug", "Fission",
        "Live HTTP headers",
        'Chromifox Companion',
        'Chromifox Extreme']
    plugins.each do |plug|
        results = capture_all("grep #{plug} -r /home/da01/.mozilla/firefox --include=extensions.rdf")
        shout "Install #{plug} for Firefox" if !results[plug]
    end
  end

  def install_vim

    vimrc = (MY_PREFS / 'vim/vimrc.vim')
    new_vim_rc = Pow('~/.vimrc')
    if !new_vim_rc.exists?
        shout(capture_all('ln -s %s %s' % [vimrc.to_s.inspect, new_vim_rc.to_s.inspect] ))
    end

    bash_file = Pow(File.expand_path('~/.bashrc')).read
    if !bash_file['gvim --remote-tab-silent']
        shout('Put alias gvim="gvim --remote-tab-silent" at the end of your ~/.bashrc file.')
    end

    vivid = (MY_PREFS / 'vim' / 'dotvim')
    home_vivid = Pow(File.expand_path('~/.vim'))
    both_exists = vivid.exists? && home_vivid.exists?
    both_match = both_exists && File.symlink?(home_vivid.to_s)
    do_install = vivid.exists? && !both_exists
    if both_exists && !both_match
        shout( "Delete #{home_vivid}"  )
    elsif do_install
        shout(capture_all("ln -s %s %s" % [vivid.to_s.inspect, home_vivid.to_s.inspect]))
    end
  end

  def install_irb

    home_irb = Pow(File.expand_path("~/.irbrc"))
    irb = (MY_PREFS / 'ruby' / 'irbrc.rb')

    both_exist = home_irb.exists? && irb.exists?
    both_match = both_exist &&
                    (home_irb.read.strip == irb.read.strip) &&
                        File.symlink?(home_irb.to_s)


    install_irb = !both_exist && irb.exists?

    if both_exist && !both_match
        shout "DELETE file: #{home_irb}"
    end

    if install_irb
        shout `gem install wirble` if !capture_all('gem list')['wirble']
        shout(capture_all("ln -s %s %s" % [irb.to_s.inspect, home_irb.to_s.inspect]))
    end
  end

  def install_gemrc
    gem_rc_yaml = (MY_PREFS / 'ruby' / 'gemrc.yaml')
    gem_rc = Pow( '~/.gemrc' )
    both_exists = gem_rc_yaml.exists? && gem_rc.exists?
    both_match = both_exists &&
                  gem_rc_yaml.read.strip == gem_rc.read.strip &&
                    File.symlink?(gem_rc.to_s)
    do_link = gem_rc_yaml.exists? && !both_exists

    if do_link
        shout capture_all('ln -s %s %s' % [gem_rc_yaml.to_s.inspect,  gem_rc.to_s.inspect] )
    else
        shout "#{gem_rc_yaml} not found." if !gem_rc_yaml.exists?
        shout "#{gem_rc} must be deleted." if both_exists && !both_match
    end

    invoke('gems:update')

  end

  def install_light_conf

    light_conf = (MY_PREFS / 'light.conf')
    sudo_light_conf = Pow("/etc/lighttpd/lighttpd.conf")

    if !light_conf.exists?
        shout "File not found: #{light_conf}"
        return nil
    end

    both_exist = light_conf.exists? && sudo_light_conf.exists?
    both_match = both_exist && ( light_conf.read.strip != sudo_light_conf.read.strip )

    if both_exist && !both_match
        shout( "Sudo copy file to #{sudo_light_conf}" )
        return false
    end

    true

  end

  def install_open_with_gvim_tabs
    # http://stackoverflow.com/questions/1323790/have-nautilus-open-file-into-new-gvim-buffer
    desktop_file = Pow('~/.local/share/applications/gvim-tab.desktop')
    if !desktop_file.exists?
      desktop_file.create { |f|
        f.puts %~
[Desktop Entry]
Encoding=UTF-8
Name=GVim Text Editor (Tabs)
Comment=Edit text files in a new tab
Exec=gvim --remote-tab %F
Terminal=false
Type=Application
Icon=/usr/share/pixmaps/vim.svg
Categories=Application;Utility;TextEditor;
StartupNotify=true
MimeType=text/plain;
NoDisplay=true
        ~.strip
      }
    end
  end



end # === class NewComputer

