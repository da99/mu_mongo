require 'json'
require 'rest_client'
    
class Db 
  include FeFe
  
  describe :migrate  do
    it "Migrate to latest version of the Design_Doc."
    steps { 
      puts_white "Please wait..."
      db_connect!
      results = Design_Doc.create_or_update
      puts_white "Done migrating up."
      results
    }
  end # === 
  
  
  describe :reset! do
    it "Migrate to version 0, then migrate up to latest version." 

    
    steps {
      conn = 'https://da01tv:isleparadise4vr@localhost/'
    
      db_name = 'megauni-test'
      db_conn = "#{conn}#{db_name}/"
      all_dbs = JSON.parse(RestClient.get "#{conn}_all_dbs/")

      RestClient.delete db_conn if all_dbs.include?(db_name)
      RestClient.put db_conn , {}
      puts_white "Created: #{db_name}"
    }
  end # ===
  
  
  private  # =================================================================
 
  def db_connect!
    ENV['RACK_ENV'] ||= 'development'
    require '~/megauni/megauni'.expand_path
  end
  
end # === class Db

