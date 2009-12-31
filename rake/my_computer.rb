class My_Computer

	include FeFe

  O_RDEBUG = MY_PREFS.directory.down('ruby', 'rdebugrc.rb')
  L_RDEBUG = '~/.rdebugrc'

  O_GEMRC  = MY_PREFS.directory.down('ruby', 'gemrc.yaml')
  L_GEMRC  = '~/.gemrc'

  O_IRB_RC = MY_PREFS.directory.down('ruby', 'irbrc.rb')
  L_IRB_RC = '~/.irbrc'

  GCONF    = File.expand_path('~/.gconf/desktop/gnome/file_views/%gconf.xml')

  DROPBOX  = File.expand_path('~/Dropbox')

  BZR_DIR  = MY_LIFE.directory.down('.bzr')
  BACKUP_DIR = File.join(DROPBOX, 'BACKUP_MyLife')

  O_VIMRC = MY_PREFS.directory.down('vim/vimrc.vim')
  L_VIMRC = '~/.vimrc'

  O_DOT_VIM = MY_PREFS.directory.down('vim', 'dotvim')
  L_DOT_VIM = '~/.vim'

  MY_EMAIL = 'diego@miniuni.com'
  MY_NAME = 'da01'
  
  O_BASH_PROFILE = MY_PREFS.directory.down('_bash_profile' )
  L_BASH_PROFILE = '~/.bash_profile'
  MY_DOT_PROFILE = '~/.profile'

  O_LIGHT_CONF = MY_PREFS.directory.down( 'light.conf')
  L_LIGHT_CONF = "/etc/lighttpd/lighttpd.conf"

  describe :setup do

    it %~
      Sets up your new computer.
    ~


    steps {

      # puts_white %~
      #   Flash fix for Ubuntu: 
      #   http://ubuntuforums.org/showthread.php?t=1130582&highlight=flash+problem 
      # ~

      puts_white 'ruby-debug configuration file:'
      O_RDEBUG.file.create_alias  L_RDEBUG

      puts_white 'gem configuration file:'
      O_GEMRC.file.create_alias L_GEMRC

      puts_white 'irb configuration file:'
      O_IRB_RC.file.create_alias L_IRB_RC

      puts_white %~
        Checking if hidden files are 
        displayed by default in Nautilus.
      ~.split.join(' ')

      demand_file_exists(GCONF) 
      if !GCONF.file.read['show_hidden_files']
          puts_red %~
            Always show hidden files in  Nautilus:
            http://www.watchingthenet.com/always-show-hidden-files-in-ubuntu-nautilus-file-browser.html
            Alt+F2 > gconf-editor > "desktop / gnome / file_views"
          ~
      end

      puts_white 'Creating Dropbox directory.'

      create_directory(DROPBOX)
      create_directory(BACKUP_DIR)

      if !shell_out('which dropbox')['dropbox']
        puts_red 'Install DropBox.'
      end

      if shell_out('which rsync')['rsync']
        cron_task ="cd #{MY_LIFE} && #{shell_out('which rsync').strip} -av --delete #{MY_LIFE} #{BACKUP_DIR}"
        if !shell_out('crontab -l')[cron_task]
          puts_red "Setup CRONT:"
          puts_red "crontab -e"
          puts_red "59 */3 * * * #{cron_task}"
        end
      else
        puts_red 'Install rsync and run this task again.'
      end
      
      puts_white %~
        Checking Firefox configuration...' 
        http://blogs.n1zyy.com/n1zyy/2008/09/16/firefoxs-history-setting/
      ~.split.join(' ')

      vals = {}
      vals[:"browser.history_expire_days.mirror"] = 3
      vals[:"browser.history_expire_days"] = 3
      vals[:"browser.history_expire_sites"] = 1000
      grep_vals = shell_out("grep history -r ~/.mozilla/firefox --include=prefs.js")

      vals.each do |k,v|
        if !grep_vals[/#{k}...#{v}/]
          puts_red "Change Firefox option: #{k} ===>> #{v}" 
        end
      end

      plugins = [ 
          "Adblock Plus",
          "Firebug", 
          "Fission",
          "Live HTTP headers",
          #'Chromifox Companion',
          #'Chromifox Extreme'
      ]

      plugins.each do |plug|
          results = shell_out("grep #{plug} -r /home/da01/.mozilla/firefox --include=extensions.rdf")
          puts_red( "Install #{plug} for Firefox" ) if !results[plug]
      end

      # puts_white 'Configuring Bzr.'

      # if !shell_out('which bzr')
      #   puts_red "Install bzr: https://launchpad.net/~bzr/+archive/ppa"
      # else
      #   shell_out('bzr whoami "%s <%s>"' % [MY_NAME, MY_EMAIL])
      # end

      puts_white 'Checks for git.'

      if !shell_out('which git')['git']
        puts_red 'Install git with PPA.'
      else
        results = shell_out('git config --global user.name %s' % MY_NAME.inspect)
        results += shell_out('git config --global user.email %s' % MY_EMAIL)
        if !results.strip.empty?
          puts_red( results )
        end
      end

      puts_white 'Linking VIM configuration file.'
      
      O_VIMRC.file.create_alias( L_VIMRC )

      puts_white 'Linking VIM dot directory.'
      O_DOT_VIM.directory.create_alias  L_DOT_VIM

      puts_white 'Installing bash profile.'
      if !MY_DOT_PROFILE.file.read['. "$HOME/.bash_profile"']
        puts_red %~ 
					Add the following to your .profile:
					if [ -f "$HOME/.bash_profile" ]; then
					. "$HOME/.bash_profile"
					fi
				~
      end


      puts_white 'Checking for Lighttd config.'


      # if !L_LIGHT_CONF.file? 
      #   puts_red( "Sudo copy file to #{L_LIGHT_CONF}" )
      # end

    } # === steps

  end 

end # === FeFe_Setup_My_Computer


__END__


  if !Pow('/etc/passwd').read['nginx_www']
    puts_red "Execute the following: "
    puts_red 'sudo adduser --system --home /home/da01/Documents/nginx_data --no-create-home  --shell /bin/bash --group --gecos "Nginx WWW Admin" nginx_www'
    puts_red 'chown -R nginx_www:nginx_www /home/da01/Documents/nginx_data'
    puts_red 'chmod -R 0770 /home/da01/Documents/nginx_data'
  end
  
  puts_white %~
    Setups Cron.
  ~
  cron_task ="cd #{MY_LIFE()} && #{shell_out('which fefe')} bzr:my_life_dev_check"
  if !shell_out_all('crontab -l')[cron_task]
    puts_white "Setup CRONT:"
    puts_white "crontab -e"
    puts_white "59 */3 * * * #{cron_task}"
  end

