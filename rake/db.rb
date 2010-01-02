def db_connect!
  ENV['RACK_ENV'] ||= 'development'
  @main_file ||= begin
                   require File.basename(File.expand_path('.'))
                 end
end

namespace :db do
  
  desc "Migrate to version 0, then migrate up to latest version." 
  task :reset! do
    
    db_connect!

    RestClient.delete CouchDB_CONN.url_base 
    puts_white "Deleted: #{CouchDB_CONN.db_name}"

    RestClient.put CouchDB_CONN.url_base , {}
    puts_white "Created: #{CouchDB_CONN.db_name}"

    CouchDB_CONN.create_design
    
  end # ===
  
end # === namespace :db

