

configure :test do
  CouchDB_URI = "https://da01tv:isleparadise4vr@localhost"
  DB_NAME = 'megauni-test'
  DB_CONN = File.join(CouchDB_URI, DB_NAME)
end


configure :development do
  require Pow('helpers/sinatra/css')
  CouchDB_URI = "https://da01tv:isleparadise4vr@localhost"
  DB_NAME = "megauni-dev"
  DB_CONN = File.join( CouchDB_URI, DB_NAME )
end


configure(:production) do
  CouchDB_URI = "http://un**:pswd**@127.0.0.1:5984/" 
  DB_NAME = 'megauni-production'
  DB_CONN = File.join(CouchDB_URI, DB_NAME)
end


# =====================================================================================
#                              All Environments
# =====================================================================================
configure do

  # 
  # Raise this when it's possible this situation occurred:
  #   * Client requests HTML page.
  #   * New code is pushed by developer to server.
  #   * Client uses outdate HTML form to send data.
  #
  module ApiChange
    class ApiChangeError < StandardError
      attr_accessor :class_name, :keys
      def initialize(class_obj, *keys)
        @class_name = class_obj.to_s
        @keys = keys
        msg = "#{self.class}: #{keys.inspect}"
        super(msg)
      end
    end
    class KeyMissing < ApiChangeError; end
    class KeyObsolete < ApiChangeError; end
  end

  DESIGN_DOC_ID = '_design/megauni'

  use Rack::Session::Pool  
  # Don't "enable :session" because: 
  # http://www.gittr.com/index.php/archive/using-alternate-session-stores-with-sinatra/
  
  set :site_title,        'Mega Uni'
  set :site_tag_line,     "For all your different lives: friends, family, work & romance."
  set :site_keywords,     'to-do lists predictions'
  set :site_domain,       'megaUni.com'
  set :site_help_email,     Proc.new { "helpme@#{site_domain}"  }
  set :site_url,            Proc.new { "http://www.#{site_domain}/" }
  set :site_support_email,  Proc.new { "helpme@#{site_domain}"  }
  set :cache_the_templates, Proc.new { !development? }
  set :views,               Pow('views/skins/jinx')

  require( File.expand_path './helpers/app/issue_client' )
  require( File.expand_path './helpers/app/wash' )
  #require Pow('helpers/app/model_init')

end # === configure


