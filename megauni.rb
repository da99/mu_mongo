
$KCODE = 'UTF8'
ENV['RACK_ENV'] ||= 'development'

require 'jcode'
require 'helpers/app/kernel' 
require 'middleware/The_App'  

class The_App
  
  SITE_DOMAIN        = 'megaUni.com'
  SITE_TITLE         = 'Mega Uni'
  SITE_TAG_LINE      = '?~!@#*^+!'
  SITE_HELP_EMAIL    = "help@#{SITE_DOMAIN}"
  SITE_URL           = "http://www.#{SITE_DOMAIN}/"
  ON_HEROKU          = ENV.keys.grep(/heroku/i).size > 0
end # === class

if The_App::ON_HEROKU
	class The_App
		SMTP_USER_NAME = 'unknown'
		SMTP_PASSWORD = 'unknown'
	end
else
	class The_App
		SMTP_USER_NAME = 'unknown'
		SMTP_PASSWORD = 'unknown'
	end
end

# === DB urls/connections ===
require 'models/Couch_Plastic'


# === Require models. ===

%w{
  Club
  Message
	Member
}.each { |mod| require "models/#{mod}" }


Couch_Plastic.ensure_indexes()


