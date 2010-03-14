
MY_EMAIL = 'diego@miniuni.com'
MY_NAME = 'da01'

MY_LIFE  = File.expand_path('~/MyLife')
MY_PREFS = File.join(MY_LIFE, 'prefs')
DROPBOX  = File.expand_path('~/Dropbox')
BACKUP_DIR = File.join(DROPBOX, 'BACKUP_MyLife')

class String
  def one_line
     split("\n").join(" ").strip
  end
end

namespace 'my_computer' do 

  desc 'Sets up your new computer.'
  task :setup do 

      puts_white %~
         Optional: Flash fix for Ubuntu: 
         http://ubuntuforums.org/showthread.php?t=1130582&highlight=flash+problem 
      ~

      puts_white 'ruby-debug configuration file:'
      rdebug = File.join(MY_PREFS, 'ruby', 'rdebugrc.rb')
      FiDi.file(rdebug).create_alias '~/.rdebugrc'

      puts_white 'gem configuration file:'
      gemrc = File.join(MY_PREFS, 'ruby', 'gemrc.yaml')
      FiDi.file(gemrc).create_alias '~/.gemrc'

      puts_white 'irb configuration file:'
      irbrc = File.join(MY_PREFS, 'ruby', 'irbrc.rb')
      FiDi.file(irbrc).create_alias '~/.irbrc'

      puts_white '
        Checking if hidden files are 
        displayed by default in Nautilus.
      '.one_line

      gconf = File.expand_path('~/.gconf/desktop/gnome/file_views/%gconf.xml')
      FiDi.file(gconf).must_exist 
      if !( File.read(gconf)['show_hidden_files'] )
          puts_red %~
            Always show hidden files in  Nautilus:
            http://www.watchingthenet.com/always-show-hidden-files-in-ubuntu-nautilus-file-browser.html
            Alt+F2 > gconf-editor > "desktop / gnome / file_views"
          ~
      end

      puts_white 'Creating Dropbox directory.'

      FiDi.directory(DROPBOX).mkdir
      FiDi.directory(BACKUP_DIR).mkdir

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
      ~.one_line

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
          "Live HTTP headers"
      ]

      plugins.each do |plug|
          results = shell_out("grep #{plug} -r /home/da01/.mozilla/firefox --include=extensions.rdf")
          if not results[plug]
            puts_red( "Install #{plug} for Firefox" )
          end
      end

      puts_white 'Checks for git.'

      if not shell_out('which git')['git']
        puts_red 'Install git with PPA.'
      else
        results = shell_out('git config --global user.name %s' % MY_NAME.inspect)
        results += shell_out('git config --global user.email %s' % MY_EMAIL)
        if not results.strip.empty?
          puts_red( results )
        end
      end

      puts_white 'Linking VIM configuration file.'
      
      FiDi.file(MY_PREFS, 'vim/vimrc.vim').create_alias( '~/.vimrc' )

      puts_white 'Linking VIM dot directory.'
      FiDi.directory(MY_PREFS, 'vim', 'dotvim').create_alias '~/.vim'

      puts_white 'Installing bash profile.'
      bashrc = '~/.bashrc'
      custom_bashrc = '~/MyLife/prefs/_bashrc_additions'
      if not bashrc.file.read[". #{custom_bashrc}"]
        puts_red %~ 
          Add the following to your #{bashrc}:
# Custom additios for Diego
  . #{custom_bashrc}
        ~
      end

  end # task

end # namespace

