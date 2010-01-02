def db_connect!
  ENV['RACK_ENV'] ||= 'development'
  require File.basename(File.expand_path('.'))
end

namespace :db do
  
  desc "Migrate to latest version of the Design_Doc."
  task :update_view_doc  do
    db_connect!
    CouchDB_CONN.create_or_update_design
    puts_white "Updated view document."
  end # === 
  
  
  desc "Migrate to version 0, then migrate up to latest version." 
  task :reset! do
    
    db_connect!

    RestClient.delete CouchDB_CONN.url_base 
    puts_white "Deleted: #{CouchDB_CONN.db_name}"

    RestClient.put CouchDB_CONN.url_base , {}
    puts_white "Created: #{CouchDB_CONN.db_name}"

    Rake::Task['db:update_view_doc'].invoke
    
  end # ===
  
end # === namespace :db

