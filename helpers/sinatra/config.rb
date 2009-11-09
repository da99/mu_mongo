

configure :test do
  DB_CONN = "https://localhost/megauni-test"
end


configure :development do
  require Pow('helpers/sinatra/css')
  # DB_CONN = "http://da01tv:isleparadise4vr@127.0.0.1:5984/megauni-dev"
  DB_CONN = "https://localhost/megauni-dev"
end


configure(:production) do
  DB_CONN = "http://un**:pswd**@127.0.0.1:5984/megauni-production"
end


# =====================================================================================
#                              All Environments
# =====================================================================================
configure do

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


