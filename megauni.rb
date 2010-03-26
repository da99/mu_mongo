
$KCODE = 'UTF8'
ENV['RACK_ENV'] ||= 'development'

require 'jcode'

# === Important Gems ===
require 'multibyte'
require 'cgi' # Don't use URI.escape because it does not escape all invalid characters.


# === App Helpers ===
require( 'helpers/app/require'  )
require_these 'helpers/app', %w{
    kernel
    chars_compat
    string_additions
    string_blank
    string_inflections
    read_if_file
    symbolize_keys
    json
    data_pouch
}
  

require 'middleware/The_App'  

class The_App
  
  module Options
    SITE_DOMAIN        = 'megaUni.com'
    SITE_TITLE         = 'Mega Uni'
    SITE_TAG_LINE      = 'A site for bored people.'
    SITE_HELP_EMAIL    = "helpme@#{SITE_DOMAIN}"
    SITE_URL           = "http://www.#{SITE_DOMAIN}/"
    SITE_SUPPORT_EMAIL = "helpme@#{SITE_DOMAIN}"
    VIEWS_DIR          = 'views/skins/jinx' # .expand_path
    SITE_KEYWORDS      = 'office games'
    LANGUAGES          = ['English']
  end
  
end # === class


# === DB urls/connections ===

require 'models/Couch_Doc'

case ENV['RACK_ENV']
  
  when 'test'
    CouchDB_CONN = Couch_Doc.new(
      # "https://da01tv:isleparadise4vr@localhost",
      'http://localhost:5984',
      'megauni-test' 
    )
    
  when 'development'
    CouchDB_CONN = Couch_Doc.new(
      # "https://da01tv:isleparadise4vr@localhost",
      'http://localhost:5984',
      'megauni-dev' 
    )

  when 'production'
    CouchDB_CONN = Couch_Doc.new(
      "http://un**:pswd**@127.0.0.1:5984/",
      'megauni-production' 
    )

  else
    raise ArgumentError, "Unknown RACK_ENV value: #{ENV['RACK_ENV'].inspect}"

end # === case


# === Require models. ===

require_these 'models', %w{
  Couch_Plastic
  Club
  Message
	Member
}     


CouchDB_CONN.create_or_update_design


