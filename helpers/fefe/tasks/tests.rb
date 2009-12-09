$LOAD_PATH.unshift File.expand_path('specs/fefe')

class Tests
  
  include FeFe
  include Color_Puts

  describe :run do

    it %! Runs FeFe tests for your app in the fefe/ directory. !

    steps([:file, nil], [:inspect, nil]) { |file, inspect_test|

      puts_white " ===================================== "
      rb_files = if file
                   new_file = new_file_rb = File.expand_path(File.join('specs/fefe/',file))
                   new_file_rb += '.rb' unless new_file[/\.rb$/]
									 new_file = new_file.sub(/\.rb$/, '')
                   demand_file_exists new_file_rb
                   [new_file]
                 else
                  'specs/fefe/'.ruby_files_wo_rb
                 end
      
      if inspect_test
        FeFe_Test.inspect_test inspect_test
      end

      rb_files.each { |rb_file|
        class_name = File.basename(rb_file).split('_').map(&:capitalize).join('_')
        require rb_file
        ft_class = Object.const_get(class_name)
      }
      
      total, passed, failed = FeFe_Test.results # [total, passed, failed] == [ 5, 3, 2] 
			puts ''
			if total == passed
				puts_green " * * * * * * * * * * * * * * * * * * * "
				puts_green "      ALL TESTS PASSSED: #{total}"
				puts_green " * * * * * * * * * * * * * * * * * * * "
			else
				puts_red   " * * * * * * * * * * * * * * * * * * * "
				puts_multi :red, "  FAILED: #{failed}", :white, ', ', :green, " PASSED: #{passed}"
				puts_red   " * * * * * * * * * * * * * * * * * * * "
			end
			puts ''
    }

  end # ======== :run
  
  describe :db_reset! do
    
    it "Reset the :test database"
    
    steps do
      fefe_run('db:reset!')

      ENV['RACK_ENV'] = 'test'
      require File.expand_path('megauni')

      DesignDoc.create_or_update
      puts_white 'Created: design doc.'

      # === Create News ==========================
      
      CouchDoc.PUT( 'i-luv-longevinex', {:title=>'Longevinex', 
        :teaser=>'teaser', 
        :body=>'Test body.', 
        :tags=>['surfer_hearts', 'hearts', 'pets']
      })

      # === Create Members ==========================
      
      CouchDoc.PUT("member-regular-member-1",
        { :hashed_password => "$2a$10$QvMeyHgmdik6e0jUO3ceb.S1ezikJDobUkCy9xID/b4jL.WlMp2Rq",
          :salt            => "yJ2OuJpdIy",
          :data_model      => "Member",
          :created_at      => "2009-12-09 08:31:36",
          :lives           => { "friend" => {'username' => "regular-member"} }
        }
      )
      
      CouchDoc.PUT("username-regular-member",  {:member_id =>"member-regular-member-1"} )

      CouchDoc.PUT("member-admin-member-1",
        { :hashed_password => "$2a$10$cTAyJogAm7zOe0XM2KOeJu4nsco2/uP7fKAVfLq0haGtDxEfC.gv.",
          :salt            => "4LKK5YOOLX",
          :data_model      => "Member",
          :created_at      => "2009-12-09 08:31:36",
          :lives           => { "friend" => {'username' => "admin-member"} }
        }
      )

      CouchDoc.PUT("username-admin-member", {:member_id =>	"member-admin-member-1"}       )
      
      # admin_mem = Member.by_username( 'admin-member' )
      # admin_mem.new_data.security_level = :ADMIN
      # admin_mem.save_update
      
    end
  end # ======== :db_reset!
    
end # ======== Tests

module FeFe_Test
  
  include Demand_Arguments_Dsl
	include Color_Puts
  
  def on_assertion_exit 
    lambda {
			if FeFe_Test.inspect_test? && FeFe_Test.inspect_test == FeFe_Test.count
				puts @assertion_call_back
				puts @assertion_exit_msg
				exit(1)
			end
			raise DemandFailed, assertion_exit_msg
		}
  end

	def self.results
		[@count.to_i, @count_passed.to_i, @count_failed.to_i ]
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
      @inspect_test
    end
  end

  def self.inspect_test?
    @inspect_test && @count == @inspect_test
  end

  def self.inspection?
    !!@inspect_test
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

      f_unit = new(title, FeFe_Test.count, @before, @after )
      
      f_unit.run blok
    end
    
    def before &blok
      @before = blok
    end
    
    def after &blok
      @after = blok
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
      instance_eval &@before
    end
    
    @results = begin
      
      if FeFe_Test.inspection? && FeFe_Test.inspect_test?
        require 'rubygems'; require 'ruby-debug'; debugger
      end

      instance_eval &body
      [ true, "ok" ]
    rescue Object => e
      [ false, e.message, e ]
    end

    if @after
      instance_eval &@after
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
					puts l if l[FeFe_The_French_Maid::Prefs::PRIMARY_APP] && 
						!l['instance_eval'] && !l['__fefe']
				}
			end
			puts ''
    end

  end

end # ======== FeFe_Test

