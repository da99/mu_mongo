
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

    # Grab some sample data
    Rake::Task['db:sample_data'].invoke
    
    if ENV['RACK_ENV'] === 'test'
      Rake::Task['db:test_sample_data'].invoke
    end
  end # ===

  desc 'Grab some sample data from production database'
  task :sample_data do
    require 'json'
    require File.basename(File.expand_path('.'))
    # Grab some sample data
    base_url = File.read(File.expand_path '~/cloud.txt').strip
    url      = File.join( base_url, "/_design/web/_view/messages_by_club_id" )
    docs     = JSON.parse(RestClient.get(url + '?limit=5&include_docs=true').body)['rows']
    docs.each { |d|
      d['doc'].delete 'rev'
      CouchDB_CONN.PUT d['doc']['_id'], d['doc']
    }
    puts_white "Inserted sample data."
  end

  desc 'Update design document only. Uses ENV[\'RACK_ENV\']. Development by default.'
  task :reset_design_doc do
    ENV['RACK_ENV'] ||= 'development'
    require File.basename(File.expand_path('.'))
    CouchDB_CONN.create_or_update_design
    puts_white "Updated design doc."
  end
  
  desc "Add in sample data for tests."
  task :test_sample_data do
    
    # === Create Clubs ==========================

    CouchDB_CONN.PUT( 'club-hearts', {:filename=>'hearts', 
                  :title=>'The Hearts Club',
                  :lang => 'English',
                  :created_at => '2009-12-27 08:00:01',
                  :data_model => 'Club'
    } )

    # === Create News ==========================

    CouchDB_CONN.PUT( 'hearts-news-i-luv-longevinex', {:title=>'Longevinex', 
                  :teaser   =>'teaser', 
                  :body     =>'Test body.', 
                  :tags     =>['surfer_hearts', 'hearts', 'pets'],
                  :created_at   =>'2009-10-11 02:02:27',
                  :published_at =>'2009-12-09 01:01:26',
                  :data_model   => 'News', 
                  :club_id      => 'club-hearts'
    })


    # === Create Regular Member 1 ==========================

    CouchDB_CONN.PUT("member-regular-member-1", # password: regular-password
                  { :hashed_password => "$2a$10$KEcTkN2c3pJeHeLczzupi.B67yQI3rH0evr8tb9gmdGnv686O9jfq",
                    :salt            => "yJ2OuJpdIy",
                    :data_model      => "Member",
                    :created_at      => "2009-12-09 08:31:36",
                    :lives           => { "friend" => {'username' => "regular-member-1"} },
                    :security_level  => :MEMBER
    }
    )

    CouchDB_CONN.PUT("username-regular-member-1",  {:member_id =>"member-regular-member-1"} )
    
    # === Create Regular Member 2 ==========================

    CouchDB_CONN.PUT("member-regular-member-2", # password: regular-password
                  { :hashed_password => "$2a$10$KEcTkN2c3pJeHeLczzupi.B67yQI3rH0evr8tb9gmdGnv686O9jfq",
                    :salt            => "yJ2OuJpdIy",
                    :data_model      => "Member",
                    :created_at      => "2009-12-09 08:35:36",
                    :lives           => { "family" => {'username' => "regular-member-2"},
                                          "work"   => {'username' => "regular-member-2-work"}},
                    :security_level  => :MEMBER
    }
    )

    CouchDB_CONN.PUT("username-regular-member-2",  {:member_id =>"member-regular-member-2"} )
    
    # === Create Regular Member 3 ==========================

    CouchDB_CONN.PUT("member-regular-member-3", # password: regular-password
                  { :hashed_password => "$2a$10$KEcTkN2c3pJeHeLczzupi.B67yQI3rH0evr8tb9gmdGnv686O9jfq",
                    :salt            => "yJ2OuJpdIy",
                    :data_model      => "Member",
                    :created_at      => "2009-12-09 08:35:36",
                    :lives           => { "work" => {'username' => "regular-member-3"} },
                    :security_level  => :MEMBER
    }
    )

    CouchDB_CONN.PUT("username-regular-member-3",  {:member_id =>"member-regular-member-3"} )


    # === Create Admin Member ==========================

    CouchDB_CONN.PUT("member-admin-member-1", # password: admin-password
                     { :hashed_password => "$2a$10$56l0GJQM8/En5rarzBOzIOqHiaKt0SAuMCKwHlRE/HnYJ1pbpT2Lu",
                       :salt            => "4LKK5YOOLX",
                       :data_model      => "Member",
                       :created_at      => "2009-12-09 08:31:36",
                       :lives           => { "friend" => {'username' => "admin-member-1"} },
                       :security_level  => :ADMIN
    }
    )

    CouchDB_CONN.PUT("username-admin-member-1", {:member_id =>	"member-admin-member-1"}       )
    puts_white 'Inserted sample data just for tests.'
  end # ======== :db_reset!
end # === namespace :db

