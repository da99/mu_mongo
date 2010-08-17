
$KCODE = 'UTF8'
ENV['RACK_ENV'] ||= 'development'

require 'jcode'
require 'helpers/app/kernel' 
require 'middleware/The_App'  

class The_App
  
  SITE_DOMAIN        = 'megaUni.com'
  SITE_TITLE         = 'Mega Uni'
  SITE_NAME          = 'Mega Uni'
  SITE_TAG_LINE      = "Create your own universe(s)."
  SITE_HELP_EMAIL    = "help@#{SITE_DOMAIN}"
  SITE_URL           = "http://www.#{SITE_DOMAIN}/"
  ON_HEROKU          = ENV.keys.grep(/heroku/i).size > 0
end # === class

if The_App::ON_HEROKU
  class The_App
    SMTP_AUTHENTICATION = :plain 
    SMTP_ADDRESS   = 'smtp.sendgrid.net'
    SMTP_USER_NAME = ENV['SENDGRID_USERNAME']
    SMTP_PASSWORD  = ENV['SENDGRID_PASSWORD']
    SMTP_DOMAIN    = ENV['SENDGRID_DOMAIN']
  end
else
  class The_App
    SMTP_AUTHENTICATION = :plain 
    SMTP_ADDRESS   = 'unknown'
    SMTP_USER_NAME = 'username'
    SMTP_PASSWORD  = 'password'
    SMTP_DOMAIN    = 'unknown'
  end
end

# === DB urls/connections ===
require 'models/Couch_Plastic'


# === Require models. ===

%w{
  Doc_Log
  Club
  Message
  Member
}.each { |mod| require "models/#{mod}" }



