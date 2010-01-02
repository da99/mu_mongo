
namespace :tests do
  

  desc %! Runs FeFe tests for your app in the fefe/ directory. !
  task :all do

    rb_files = Dir.glob('tests/test_*.rb').sort.reverse.map { |file| file.sub('.rb', '')}
    
    rb_files.each { |file|
      require file 
    }

  end # ======== :run

  desc "Run one test file. Uses: name=. 'tests/tests_' and '.rb' is automatically added."
  task :file do
    # require "tests/test_#{ENV['name']}"
    sh(%~ ruby -w "tests/test_#{ENV['name']}.rb"~)
  end
  
  desc "Creates a test file. Uses name=. Addes 'test_' and '.rb' automatically."
  task :create do
    name = ENV['name'].strip
    raise "Must not be empty." if name.empty?

    file_path = "tests/test_#{name}.rb"
    if File.exists?(file_path)
      raise "File may not be overwritten: #{file_path.inspect}"
    end

    content = File.read("tests/__template__.txt").gsub("{{name}}", name)
    File.open(file_path, 'w') do |file|
      file.puts content
    end

    puts_white "Created:"
    puts file_path
  end
  
  desc "Reset the :test database"
  task :db_reset! do
    
    ENV['RACK_ENV'] ||= 'test'
    Rake::Task['db:reset!'].invoke

    # === Create Clubs ==========================

    CouchDB_CONN.PUT( 'club-hearts', {:filename=>'hearts', 
                  :title=>'The Hearts Club',
                  :lang => 'English',
                  :created_at => '2009-12-27 08:00:01',
                  :data_model => 'Club'
    } )

    # === Create News ==========================

    CouchDB_CONN.PUT( 'i-luv-longevinex', {:title=>'Longevinex', 
                  :teaser   =>'teaser', 
                  :body     =>'Test body.', 
                  :tags     =>['surfer_hearts', 'hearts', 'pets'],
                  :created_at   =>'2009-10-11 02:02:27',
                  :published_at =>'2009-12-09 01:01:26',
                  :data_model   => 'News', 
                  :club     => 'surfer-hearts'
    })


    # === Create Regular Member ==========================

    CouchDB_CONN.PUT("member-regular-member-1",
                  { :hashed_password => "$2a$10$QvMeyHgmdik6e0jUO3ceb.S1ezikJDobUkCy9xID/b4jL.WlMp2Rq",
                    :salt            => "yJ2OuJpdIy",
                    :data_model      => "Member",
                    :created_at      => "2009-12-09 08:31:36",
                    :lives           => { "friend" => {'username' => "regular-member-1"} },
                    :security_level  => :MEMBER
    }
                 )

                 CouchDB_CONN.PUT("username-regular-member-1",  {:member_id =>"member-regular-member-1"} )

                 # === Create Admin Member ==========================

                 CouchDB_CONN.PUT("member-admin-member-1",
                               { :hashed_password => "$2a$10$cTAyJogAm7zOe0XM2KOeJu4nsco2/uP7fKAVfLq0haGtDxEfC.gv.",
                                 :salt            => "4LKK5YOOLX",
                                 :data_model      => "Member",
                                 :created_at      => "2009-12-09 08:31:36",
                                 :lives           => { "friend" => {'username' => "admin-member-1"} },
                                 :security_level  => :ADMIN
                 }
                              )

                              CouchDB_CONN.PUT("username-admin-member-1", {:member_id =>	"member-admin-member-1"}       )
      
  end # ======== :db_reset!
    
end # ======== Tests



__END__
module FeFe_Test
  
  

	def self.results
    @count ||= 0
    @count_passed ||= 0
    @count_failed ||= 0
		[@count, @count_passed, @count_failed ]
	end

  def self.count
    @count ||= 0
  end

  def self.add_count
    @count ||=0
    @count += 1
  end

	def self.add_passed_count
		@count_passed ||= 0
		@count_passed+=1
	end

	def self.add_failed_count
		@count_failed ||= 0
		@count_failed += 1
	end

  def self.inspect_test raw_num = nil
    if raw_num
      @inspect_test = raw_num.to_i
    else
      @inspect_test ||= nil
    end
  end

  def self.inspect_test?
    @inspect_test && @count == @inspect_test
  end

  def self.inspection?
    !!inspect_test
  end

  def self.included new_class
    new_class.send :extend, Class_Methods
  end
  
  module Class_Methods
    
    
    def set_counter new_count
      @count = 0
    end

    def add_count
      FeFe_Test.add_count
    end

    def it title, &blok
      add_count
      
      if FeFe_Test.inspection? && !FeFe_Test.inspect_test?
        return false
      end

      f_unit = new(title, FeFe_Test.count, before, after )
      
      f_unit.run blok
    end
    
    def before &blok
      if block_given?
        @before = blok
      else
        @before ||= nil
      end
    end
    
    def after &blok
      if block_given?
        @after = blok
      else
        @after ||= nil
      end
    end

    def context title
      if FeFe_Test.inspection? 
        return false
      end 
      @context = title
      puts ' *' * 19
      puts ' CONTEXT: ' + title
      puts ''
    end

    def total_tests
      @count
    end
    
  end # ======== Class_Methods
  
  def initialize title, count, before, after
    
    @title  = title
    @count  = count
    @before = before
    @after  = after
      
  end

  def run body
    if @before
      instance_eval( &@before )
    end
    
    @results = begin
      
      if FeFe_Test.inspection? && FeFe_Test.inspect_test?
        require 'rubygems'; require 'ruby-debug'; debugger
      end

      instance_eval( &body )
      [ true, "ok" ]
    rescue Object => e
      [ false, e.message, e ]
    end

    if @after
      instance_eval( &@after )
    end
    
    if @results.first
			FeFe_Test.add_passed_count
      puts "  ok   : #{@count}: #{@title}" 
    else
			FeFe_Test.add_failed_count
      puts ''
      puts_red "  FAIL: #{@count}: #{@title}"
			puts_white "  #{@results[2].class}: #{@results[1]} "
			if !@results[2].backtrace.first['on_assertion_exit']
				@results[2].backtrace.each { |l|
					puts l  if (!l['lib/ruby/gems'] && !l['lib/ruby/site_ruby'] && !l['bin/fefe'] && !l['fefe/tasks'])  || (@results[2].backtrace.index(l) < 2)
          # if l[FeFe_The_French_Maid::Prefs::PRIMARY_APP] && 	!l['instance_eval'] && !l['__fefe']
				}
			end
			puts ''
    end

  end

end # ======== FeFe_Test

