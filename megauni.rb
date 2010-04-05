
$KCODE = 'UTF8'
ENV['RACK_ENV'] ||= 'development'

require 'jcode'
require 'helpers/app/kernel' 
require 'middleware/The_App'  

class The_App
  
  SITE_DOMAIN        = 'megaUni.com'
  SITE_TITLE         = 'Mega Uni'
  SITE_TAG_LINE      = 'A site full of clubs.'
  SITE_HELP_EMAIL    = "help@#{SITE_DOMAIN}"
  SITE_URL           = "http://www.#{SITE_DOMAIN}/"
  
end # === class


# === DB urls/connections ===
require 'models/Couch_Plastic'


# === Require models. ===

%w{
  Club
  Message
	Member
}.each { |mod| require "models/#{mod}" }


Couch_Plastic.ensure_indexes()


