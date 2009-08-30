class NewComputer
  include Blato
  bla  :start, "Prints out info. and checks installed gems. Safe to run multiple times."  do
    shout "Install bzr: https://launchpad.net/~bzr/+archive/ppa", :white
    shout "Install git: ", :white    
    
    shout "Install mercurial: https://launchpad.net/~mercurial-ppa/+archive/stable-snapshots", :white
    
    shout "Firefox: browser.history_expire_days.mirror && browser.history_expire_days to 3: http://blogs.n1zyy.com/n1zyy/2008/09/16/firefoxs-history-setting/", :white
    shout "Firefox: browser.history_expire_sites to '400'", :white
    
    Pow(File.expand_path('~/.hgrc')).create { |f| 
      f.puts( %~
[ui]
username = %s <%s>      
      ~.strip % [MY_NAME, MY_EMAIL] )
    }
    shout capture('git config --global user.name %s' % MY_NAME.inspect)
    shout capture('git config --global user.email %s' % MY_EMAIL)
    shout capture('bzr whoami "%s <%s>"' % [MY_NAME, MY_EMAIL])
    shout %~ 
             Make sure Postgresql is installed. 
             Then install: \nsudo apt-get install postgresql-server-dev-8.x. 
             Replace 'x' with the latest Postgresql version you are using. 
             If it still does not work: try using the 'postgres' gem instead. 
             More info: http://rubyforge.org/projects/ruby-pg 
          ~ 
    shout %~ 
            Always show hidden files in  Nautilus: 
            http://www.watchingthenet.com/always-show-hidden-files-in-ubuntu-nautilus-file-browser.html
            Alt+F2 > gconf-editor > "desktop / gnome / file_views"
    ~, :white
    
    shout "Installing VIM settings.", :white
    vim_bk = Pow('~/.vim-tmp')
    if !vim_bk.exists?
        shout "Creating #{vim_bk}", :yellow
        shout capture("mkdir %s" % vim_bk.to_s), :white
    end
    Pow(File.expand_path('~/.vimrc')).create do |f|
      f.puts <<-EOF
colorscheme vividchalk
set tabstop=4
set shiftwidth=4
set autoindent
set expandtab
set smarttab

set number
set hlsearch
syntax on

if has("gui_running")
    set guifont=Liberation\ Mono\ 14
endif

autocmd FileType make     set noexpandtab
autocmd FileType python   set noexpandtab

let g:fuzzy_ignore = "*.log"
let g:fuzzy_matching_limit = 70

map <leader>f :FuzzyFinderFile<CR>
map <leader>b :FuzzyFinderBuffer<CR>
map <leader>d :execute 'NERDTreeToggle ' . getcwd()<CR>


set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

EOF
# From: http://weblog.jamisbuck.org/2008/11/17/vim-follow-up
# From: http://items.sjbach.com/319/configuring-vim-right
    end
    
    bash_file = Pow(File.expand_path('~/.bashrc')).read
    if !bash_file['gvim --remote-tab-silent']
        shout('Put alias gvim="gvim --remote-tab-silent" at the end of your ~/.bashrc file.')
    end
    
    shout( "Install vividchalk in ~/.vim/colors", :white ) if !Pow('~/.vim/colors/vividchalk.vim').exists?
    shout "Installing gems using task: gems:update", :yellow
    shout capture_task('gems:update'), :white
    
    if !capture('which blato')['bin/blato']
      shout "Symlink blato to a path dir."
    elsif !capture('crontab -l')['bin/blato bzr:my_life_dev_check']
      shout "Setup CRONT:", :white
      shout "crontab -e", :white
      shout "18 * * * * #{capture('which blato')} bzr:quiet_my_life_dev_check", :white 
    end
    
    irb_rc = Pow("~/.irbrc")
    irb_rc_read = %~
begin
  require 'rubygems'
  require 'wirble'

  # start wirble (with color)
  Wirble.init
  Wirble.colorize
rescue LoadError => err
  warn "Couldn't load Wirble: \#\{err\}"
end
    ~
    irb_match = File.read(irb_rc).strip == irb_rc_read.strip
    if irb_rc.exists? &&   irb_rc.file? && !irb_match
      shout "DELETE file: #{irb_rc}", :red
    else
      if !irb_rc.exists? && !irb_match
        shout `gem install wirble` if !capture('gem list')['wirble']
        irb_rc.create { |f| 
          f.puts irb_rc_read
        }
      end
    end
    
    gem_rc_yaml = (MY_PREFS / 'ruby' / 'gemrc.yaml')
    gem_rc = Pow('~/.gemrc')
    do_link = gem_rc_yaml.exists? && !gem_rc.exists?

    if do_link
        content_gem_rc = gem_rc_yaml.read
        shout capture('ln -s %s %s' % [ gem_rc.to_s.inspect, gem_rc_yaml.to_s.inspect ] )
    else
        shout "#{gem_rc_yaml} not found." if !gem_rc_yaml.exists?
        shout "#{gem_rc} must be deleted." if gem_rc.exists?
    end
    
    light_conf = (MY_PREFS / 'ligttpd.conf')
    sudo_light_conf = ("/etc/lighttpd/lighttpd.conf")


    shout "File not found: #{light_conf}"  if !light_conf.exists?
    both_files_exist = light_conf.exists? && sudo_light_conf.exists?

    if both_files_exists && light_conf.read.strip != sudo_light_conf.read.strip
        shout("Sudo copy file to #{sudo_light_conf}", :red) 
    end
    
  end

end
