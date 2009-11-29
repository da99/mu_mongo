

  O_RDEBUG = self::MY_PREFS.down_directory('ruby', 'rdebugrc.rb')
  L_RDEBUG = '~/.rdebugrc'

  O_GEMRC  = self::MY_PREFS.down_directory('ruby', 'gemrc.yaml')
  L_GEMRC  = '~/.gemrc'

  O_IRB_RC = self::MY_PREFS.down_directory('ruby', 'irbrc.rb')
  L_IRB_RC = '~/.irbrc'

  GCONF    = File.expand_path('~/.gconf/desktop/gnome/file_views/%gconf.xml')

  DROPBOX  = File.expand_path('~/Dropbox')

  BZR_DIR  = self::MY_LIFE.down_directory('.bzr')
  BACKUP_DIR = File.join(DROPBOX, 'BZR_DIR')

  O_VIMRC = self::MY_PREFS.down_directory('vim/vimrc.vim')
  L_VIMRC = '~/.vimrc'

  O_DOT_VIM = self::MY_PREFS.down_directory('vim', 'dotvim')
  L_DOT_VIM = '~/.vim'

  MY_EMAIL = 'diego@miniuni.com'
  MY_NAME = 'da01'
  
  O_BASH_PROFILE = self::MY_PREFS.down_directory('_bash_profile' )
  L_BASH_PROFILE = '~/.bash_profile'
  MY_DOT_PROFILE = '~/.profile'

  O_LIGHT_CONF = self::MY_PREFS.down_directory( 'light.conf')
  L_LIGHT_CONF = "/etc/lighttpd/lighttpd.conf"

  describe :setup do

    it %~
      Sets up your new computer.
    ~


    steps {

      whisper %~
        Flash fix for Ubuntu: 
        http://ubuntuforums.org/showthread.php?t=1130582&highlight=flash+problem 
      ~

      sym_link {
        docu 'ruby-debug configuration file:'
        from O_RDEBUG
        to   L_RDEBUG
      }

      sym_link {
        docu 'gem configuration file:'
        from O_GEMRC
        to   L_GEMRC
      }

      sym_link {
        docu 'irb configuration file:'
        from O_IRB_RC
        to   L_IRB_RC
      }

      docu %~
        Checks if hidden files are 
        displayed by default in Nautilus.
      ~

      demand_file(GCONF) do
        on_error {
          shout %~
            Always show hidden files in  Nautilus:
            http://www.watchingthenet.com/always-show-hidden-files-in-ubuntu-nautilus-file-browser.html
            Alt+F2 > gconf-editor > "desktop / gnome / file_views"
          ~
        }
        exists
        contains 'show_hidden_files'
      end

      docu 'Installing dropbox.'

      create_directory(DROPBOX)

      sym_link {
        from BZR_DIR
        to   BACKUP_DIR
      }
      if !capture('which dropbox')['dropbox']
        shout 'Install DropBox.'
      end

      docu %~
        Checking Firefox configuration...' 
        http://blogs.n1zyy.com/n1zyy/2008/09/16/firefoxs-history-setting/
      ~

      vals = {}
      vals[:"browser.history_expire_days.mirror"] = 3
      vals[:"browser.history_expire_days"] = 3
      vals[:"browser.history_expire_sites"] = 1000
      grep_vals = capture("grep history -r ~/.mozilla/firefox --include=prefs.js")

      vals.each do |k,v|
        if !grep_vals[/#{k}...#{v}/]
          shout "Change Firefox option: #{k} ===>> #{v}" 
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
          results = capture("grep #{plug} -r /home/da01/.mozilla/firefox --include=extensions.rdf")
          whisper( "Install #{plug} for Firefox" ) if !results[plug]
      end

      docu 'Configuring Bzr.'

      if !capture('which bzr')
        shout "Install bzr: https://launchpad.net/~bzr/+archive/ppa"
      else
        capture('bzr whoami "%s <%s>"' % [MY_NAME, MY_EMAIL])
      end

      docu 'Checks for git.'

      if !capture('which git')['git']
        shout 'Install git with PPA.'
      else
        shout capture_all('git config --global user.name %s' % MY_NAME.inspect)
        shout capture_all('git config --global user.email %s' % MY_EMAIL)
      end

      docu 'Linking VIM configuration file.'
      
      sym_link {
        docu
        from O_VIMRC
        to   L_VIMRC
      }

      docu 'Linking VIM dot directory.'
      
      sym_link {
        docu
        from O_DOT_VIM
        to   L_DOT_VIM
      }

      docu 'Installing bash profile.'
      if !File.read(MY_DOT_PROFILE)['. "$HOME/.bash_profile"']
        shout %~ 
					Add the following to your .profile:
					if [ -f "$HOME/.bash_profile" ]; then
					. "$HOME/.bash_profile"
					fi
				~
      end


      docu 'Checks for Lighttd config.'


      unless_file_exists(L_LIGHT_CONF) do
        shout( "Sudo copy file to #{L_LIGHT_CONG}" )
      end

    } # === steps

  end 

 # === FeFe_Setup_My_Computer


__END__


  if !Pow('/etc/passwd').read['nginx_www']
    shout "Execute the following: "
    shout 'sudo adduser --system --home /home/da01/Documents/nginx_data --no-create-home  --shell /bin/bash --group --gecos "Nginx WWW Admin" nginx_www'
    shout 'chown -R nginx_www:nginx_www /home/da01/Documents/nginx_data'
    shout 'chmod -R 0770 /home/da01/Documents/nginx_data'
  end
  
  docu %~
    Setups Cron.
  ~
  cron_task ="cd #{MY_LIFE()} && #{capture('which fefe')} bzr:my_life_dev_check"
  if !capture_all('crontab -l')[cron_task]
    whisper "Setup CRONT:"
    whisper "crontab -e"
    whisper "59 */3 * * * #{cron_task}"
  end

