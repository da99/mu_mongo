require 'json'
require 'rest_client'
    
class Db 
  include FeFe
  
  describe :migrate  do
    it "Migrate to latest version of the Design_Doc."
    steps { 
      puts_white "Please wait..."
      db_connect!
      results = CouchDB_CONN.create_or_update_design
      puts_white "Done migrating up."
      results
    }
  end # === 
  
  
  describe :reset! do
    it "Migrate to version 0, then migrate up to latest version." 

    
    steps([:env, 'test']) { |env|
      ENV['RACK_ENV'] = env
      require FeFe_The_French_Maid::Prefs::APP_NAME
      
      RestClient.delete DB_CONN 
      puts_white "Deleted: #{DB_NAME}"
      
      RestClient.put DB_CONN , {}
      puts_white "Created: #{DB_NAME}"
    }
  end # ===
  
  
  private  # =================================================================
 
  def db_connect!
    ENV['RACK_ENV'] ||= 'development'
    require '~/megauni/megauni'.expand_path
  end
  
end # === class Db

