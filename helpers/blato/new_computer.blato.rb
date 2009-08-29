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
    Pow(File.expand_path('~/.vimrc')).create do |f|
      f.puts %~ colorscheme vividchalk
set tabstop=4
set shiftwidth=4
set expandtab
set hlsearch

~
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
    
    gem_rc = Pow('~/.gemrc')
    content_gem_rc = %~
--- 
:verbose: true
:sources: 
- http://gems.rubyforge.org/
- http://gems.github.com
gem: --no-ri --no-rdoc
:update_sources: true
gempath:
  - /home/da01/.gem    
~.lstrip
    if gem_rc.exists? && gem_rc.file? && File.read(gem_rc).to_s.strip != content_gem_rc
      shout "Delete .gemrc file."
    else
      gem_rc.create {|f|
        f.puts content_gem_rc
      }
    end
    
    lighttp_config = <<-EOF
# Debian lighttpd configuration file
#

############ Options you really have to take care of ####################

## modules to load
# mod_access, mod_accesslog and mod_alias are loaded by default
# all other module should only be loaded if neccesary
# - saves some time
# - saves memory

server.modules              = (
            "mod_access",
#            "mod_alias",
            "mod_accesslog",
#            "mod_compress",
#           "mod_rewrite",
#           "mod_redirect",
"mod_proxy"
#           "mod_evhost",
#           "mod_usertrack",
#           "mod_rrdtool",
#           "mod_webdav",
#           "mod_expire",
#           "mod_flv_streaming",
#           "mod_evasive"
)

## a static document-root, for virtual-hosting take look at the
## server.virtual-* options
server.document-root       = "/var/www/"

## where to upload files to, purged daily.
server.upload-dirs = ( "/var/cache/lighttpd/uploads" )

## where to send error-messages to
server.errorlog            = "/var/log/lighttpd/error.log"

## files to check for if .../ is requested
index-file.names           = ( "index.php", "index.html",
                               "index.htm", "default.htm",
                               "index.lighttpd.html" )


## Use the "Content-Type" extended attribute to obtain mime type if possible
# mimetype.use-xattr = "enable"

#### accesslog module
accesslog.filename         = "/var/log/lighttpd/access.log"

## deny access the file-extensions
#
# ~    is for backupfiles from vi, emacs, joe, ...
# .inc is often used for code includes which should in general not be part
#      of the document-root
url.access-deny            = ( "~", ".inc" )

##
# which extensions should not be handle via static-file transfer
#
# .php, .pl, .fcgi are most often handled by mod_fastcgi or mod_cgi
static-file.exclude-extensions = ( ".php", ".pl", ".fcgi" )


######### Options that are good to be but not neccesary to be changed #######

## Use ipv6 only if available.
include_shell "/usr/share/lighttpd/use-ipv6.pl"

## bind to port (default: 80)
# server.port               = 81

## bind to localhost only (default: all interfaces)
## server.bind                = "localhost"

## error-handler for status 404
#server.error-handler-404  = "/error-handler.html"
#server.error-handler-404  = "/error-handler.php"

## to help the rc.scripts
server.pid-file            = "/var/run/lighttpd.pid"

##
## Format: <errorfile-prefix><status>.html
## -> ..../status-404.html for 'File not found'
#server.errorfile-prefix    = "/var/www/"

## virtual directory listings
dir-listing.encoding        = "utf-8"
server.dir-listing          = "enable"

## send unhandled HTTP-header headers to error-log
#debug.dump-unknown-headers  = "enable"

### only root can use these options
#
# chroot() to directory (default: no chroot() )
#server.chroot            = "/"

## change uid to <uid> (default: don't care)
server.username            = "www-data"

## change uid to <uid> (default: don't care)
server.groupname           = "www-data"

#### compress module
compress.cache-dir          = "/var/cache/lighttpd/compress/"
compress.filetype           = ("text/plain", "text/html", "application/x-javascript", "text/css")


#### url handling modules (rewrite, redirect, access)
# url.rewrite                 = ( "^/$"             => "/server-status" )
# url.redirect                = ( "^/wishlist/(.+)" => "http://www.123.org/$1" )

#
# define a pattern for the host url finding
# %% => % sign
# %0 => domain name + tld
# %1 => tld
# %2 => domain name without tld
# %3 => subdomain 1 name
# %4 => subdomain 2 name
#
# evhost.path-pattern = "/home/storage/dev/www/%3/htdocs/"

#### expire module
# expire.url                  = ( "/buggy/" => "access 2 hours", "/asdhas/" => "access plus 1 seconds 2 minutes")

#### rrdtool
# rrdtool.binary = "/usr/bin/rrdtool"
# rrdtool.db-name = "/var/www/lighttpd.rrd"

#### variable usage:
## variable name without "." is auto prefixed by "var." and becomes "var.bar"
#bar = 1
#var.mystring = "foo"

## integer add
#bar += 1
## string concat, with integer cast as string, result: "www.foo1.com"
#server.name = "www." + mystring + var.bar + ".com"
## array merge
#index-file.names = (foo + ".php") + index-file.names
#index-file.names += (foo + ".php")


#### external configuration files
## mimetype mapping
include_shell "/usr/share/lighttpd/create-mime.assign.pl"

## load enabled configuration files,
## read /etc/lighttpd/conf-available/README first
include_shell "/usr/share/lighttpd/include-conf-enabled.pl"

#### handle Debian Policy Manual, Section 11.5. urls
## by default allow them only from localhost
## (This must come last due to #445459)
## Note: =~ "127.0.0.1" works with ipv6 enabled, whereas == "127.0.0.1" doesn't
$HTTP["remoteip"] =~ "127.0.0.1" {
  alias.url += (
    "/doc/" => "/usr/share/doc/",
    "/images/" => "/usr/share/images/"
  )
  $HTTP["url"] =~ "^/doc/|^/images/" {
    dir-listing.activate = "enable"
  }
}


#### ==========================
## Custom values
## Check syntax with: lighttpd -t -f /etc/lighttpd/lighttpd.conf
## Generate certificate: openssl req -new -x509 -keyout server.pem -out server.pem -days 365 -nodes
##   -- Give it a name of 'localhost' and not your name when entering values.
##   -- Delete old custom/localhost certificates you may have in Firefox.
## Start server: sudo /etc/init.d/lighttpd start
## More info. if you get stuck: 
##     http://www.goitexpert.com/general/configuring-ssl-in-lighttpd/
##     http://redmine.lighttpd.net/projects/lighttpd/wiki/TutorialConfiguration
## More info. on SSL with proxy: 
##     http://forum.lighttpd.net/topic/73866 
##     http://www.gittr.com/index.php/archive/deploying-sinatra-via-thin-and-lighttpd/
$SERVER["socket"] == "127.0.0.1:443" {
   
   ssl.engine = "enable"
   ssl.pemfile = "#{LIFE_DIR / '/MyPrefs/server.pem'}"
   server.name = "localhost"
   server.document-root = "/home/da01/megauni/public/"

  $HTTP["host"] =~ "localhost"  {
     proxy.balance = "fair"
     proxy.server = ( "/" =>
	  ( "localhost" => ( "host" => "127.0.0.1", "port" => 4567  )
          )  

     ) 
  }

}

$HTTP["host"] =~ "localhost"  {
        proxy.balance = "fair"
        proxy.server =  ("/" =>
                                (
                                        ( "host" => "127.0.0.1", "port" => 4567 )
                                )
                        )
}
    EOF
    shout "Sudo copy file to /etc/lighttpd/ligttpd.conf", :red
  end

end
