
# PRODUCTION_DB = File.read(File.expand_path '~/cloud.txt').strip
# DB_PRODUCTION = [ File.dirname(PRODUCTION_DB), File.basename(PRODUCTION_DB) ]
namespace :db do
  
  desc "Delete, then re-create database. Uses ENV['RACK_ENV']. Defaults to 'development'." 
  task :reset! do
    
    ENV['RACK_ENV'] ||= 'development'
    raise "Not allowed in environment: #{ENV['RACK_ENV']}" unless ['development', 'test'].include?(ENV['RACK_ENV'])

    require File.basename(File.expand_path('.'))

    conn = Mongo::Connection.new
    conn.drop_database(DB.name)
    
    puts_white "Deleted: #{DB.name}"

    Couch_Plastic.create_indexes
    puts_white "Created indexes."

    # Grab some sample data
    Rake::Task['db:sample_data'].invoke
    
    if ENV['RACK_ENV'] === 'test'
      Rake::Task['db:test_sample_data'].invoke
    end
  end # ===

  desc 'Grab some sample data from production database'
  task :sample_data do
    require File.basename(File.expand_path('.'))
    
    data = JSON.parse(File.read(File.expand('tests/sample_data.json')))
    
    data.each do |doc|
      DB.collection(doc['data_model']).insert(doc)
    end
    
    puts_white "Inserted sample data."
  end

  desc 'Get all data from production database and store it as a JSON file on Desktop.'
  task :save_all_docs do
    # Grab some sample data
    require 'json'
    require 'rest_client'
    base_url = 'http://miniuni:gkz260cyxk@miniuni.cloudant.com:5984/megauni_stage'
    url      = File.join( base_url, "/_all_docs")
    mess     = JSON.parse(RestClient.get(url + '?include_docs=true').body)['rows']
    
    
    processed = mess.map { |d|
      d['doc'].delete 'rev'
      d['doc'].delete '_rev'
      if d['doc']['_id'] =~ /_design/
        nil
      else
        d['doc']
      end
    }.compact

    File.open(File.expand_path('~/Desktop/all_data.json'), 'w') do |file|
      file.puts JSON.pretty_generate(processed)
    end
    
    puts_white "Finished writing data."
    
  end

  desc 'Update design document only. Uses ENV[\'RACK_ENV\']. Development by default.'
  task :reset_design_doc do
    ENV['RACK_ENV'] ||= 'development'
    require File.basename(File.expand_path('.'))
    Couch_Plastic.create_indexes
    puts_white "Updated indexes."
  end
  
  desc "Add in sample data for tests."
  task :test_sample_data do

    raise "Not done."

    # === Create Regular Member 1 ==========================
    # === Create Regular Member 2 ==========================
    # === Create Regular Member 3 ==========================
    # === Create Admin Member ==========================
    "member-regular-member-1" # password: regular-password
    "member-regular-member-2" # password: regular-password
    "member-regular-member-3" # password: regular-password
    "member-admin-member-1" # password: admin-password


    puts_white 'Inserted sample data just for tests.'
  end # ======== :db_reset!
end # === namespace :db

