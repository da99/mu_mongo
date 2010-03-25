require 'open3'
require 'models/FiDi'

MY_EMAIL = 'diego@miniuni.com'
MY_NAME = 'da01'

HOME_MY_LIFE = '~/MyLife'
MY_LIFE  = File.expand_path(HOME_MY_LIFE)
MY_PREFS = File.join(MY_LIFE, 'prefs')
DROPBOX  = File.expand_path('~/Dropbox')
BACKUP_DIR = File.join(DROPBOX, 'Backup_MyLife')

class String
  def one_line
     split("\n").map { |str| str.strip }.join(" ").strip
  end
end

def shell_out(*args, &blok)
    stem          = args.shift
    cmd           = stem % ( args.map { |s| s.to_s.inspect } )

    results, errors = Open3.popen3( cmd ) { |stdin3, stdout3, stderr3|
      [ stdout3.readlines, stderr3.readlines ]
    }
    
    if !errors.empty?

      if block_given?
        return blok.call(results, errors)
      end
      
      puts_red '========  Error from shell_out:  =========  '
      errors.join("\n").each { |err|
        puts_red err
      }      
      
      exit(1)
      
    end
    
    results.join(" ")
end  

namespace 'my_computer' do 

  desc 'Sets up your new computer.'
  task :setup do 

      puts_white %~
         Optional: Flash fix for Ubuntu: 
         http://ubuntuforums.org/showthread.php?t=1130582&highlight=flash+problem 
      ~.one_line

      puts_white 'ruby-debug configuration file:'
      rdebug = File.join(MY_PREFS, 'ruby', 'rdebugrc.rb')
      FiDi.file(rdebug).create_alias '~/.rdebugrc'

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
          puts_red "59 */1 * * * #{cron_task}"
          puts_red "Don't use '--size-only' since that ignores bytes changes in files."
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
          "Adblock Plus"
      ]

      plugins.each do |plug|
          results = shell_out("grep #{plug} -r ~/.mozilla/firefox --include=extensions.rdf")
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

      puts_white 'Creating VIM temp dir for .swp files.'
      FiDi.directory('~/.vim-temp-files').mkdir

      puts_white 'Checking .profile'
      bashrc = File.expand_path('~/.profile')
      custom_bashrc = "#{HOME_MY_LIFE}/prefs/_bashrc_additions"
      if not File.read(bashrc)[File.basename(custom_bashrc)]
        puts_red %~ 
          Add the following to your #{bashrc}:
# Custom additios for Diego
  . #{custom_bashrc}
        ~
      end

      require 'yaml'
      puts_white 'gem configuration file:'
      gemrc                   = File.join(MY_PREFS, 'ruby', 'gemrc.yaml')
      yaml                    = YAML::load(File.read(gemrc))
      bashrc_content          = File.read(File.expand_path(custom_bashrc))
      match_in_bash_additions = bashrc_content['GEM_HOME=' + yaml["gemhome"]] &&
                                bashrc_content['GEM_PATH=' + yaml["gemhome"]]
      if not match_in_bash_additions
        puts_red "GEM_HOME and GEM_PATH are not set properly in #{custom_bashrc}"
      else
        FiDi.file(gemrc).create_alias '~/.gemrc'
      end

  end # task

end # namespace

