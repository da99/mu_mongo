
namespace :db do
  
  desc "Delete, then re-create database. Uses ENV['RACK_ENV']. Defaults to 'development'." 
  task :reset! do
    
    ENV['RACK_ENV'] ||= 'development'
    if not ['development', 'test'].include?(ENV['RACK_ENV'])
      raise "Not allowed in environment: #{ENV['RACK_ENV']}"
    end

    require File.basename(File.expand_path('.'))

    RestClient.delete CouchDB_CONN.url_base 
    puts_white "Deleted: #{CouchDB_CONN.db_name}"

    RestClient.put CouchDB_CONN.url_base , {}
    puts_white "Created: #{CouchDB_CONN.db_name}"

    CouchDB_CONN.create_design
    
  end # ===
  
end # === namespace :db

