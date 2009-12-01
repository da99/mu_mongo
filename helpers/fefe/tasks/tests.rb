$LOAD_PATH.unshift File.expand_path('specs/fefe')

class Tests
  
  include FeFe
  
  describe :run do

    it %! Runs FeFe tests for your app in the fefe/ directory. !

    steps([:file, nil], [:inspect, nil]) { |file, inspect_test|

      puts "\e[37m ===================================== \e[0m"
      rb_files = if file
                   new_file = new_file_rb = File.expand_path(File.join('specs/fefe/',file))
                   new_file_rb += '.rb' unless new_file[/\.rb$/]
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
      puts "\e[37m ===================================== \e[0m"
      
      FeFe_Test.results # [total, passed, failed] == [ 5, 3, 2] 
    }

  end # ======== :run
  
  describe :db_reset! do
    
    it "Reset the :test database"
    
    steps do
      invoke('db:reset!')

      ENV['RACK_ENV'] = 'test'
      require File.expand_path('megauni')

      DesignDoc.create_or_update
      whisper 'Created: design doc.'

      # === Create News ==========================
      
      n = News.new
      n.raw_data.update({:title=>'Longevinex', 
        :teaser=>'teaser', 
        :body=>'Test body.', 
        :tags=>['surfer_hearts', 'hearts', 'pets']
      })
      n.save_create

      # === Create Members ==========================
      
      Member.create( nil, {
        :password          =>'regular-password-1',
        :confirm_password  =>'regular-password-1',
        :add_life_username =>'regular-member-1',
        :add_life          =>Member::LIVES.first
      })
      
      Member.create( nil, {
        :password          =>'admin-password-1',
        :confirm_password  =>'admin-password-1',
        :add_life_username =>'admin-member',
        :add_life          =>Member::LIVES.first
      })

      admin_mem = Member.by_username( 'admin-member' )
      admin_mem.new_data[:security_level] = :ADMIN
      admin_mem.save_update
      
    end
  end # ======== :db_reset!
    
end # ======== Tests

module FeFe_Test
  
  include Demand_Arguments_Dsl
  
  def on_assertion_exit 
    if FeFe_Test.inspect_test? && FeFe_Test.inspect_test == FeFe_Test.count
      puts @assertion_call_back
      raise DemandFailed, assertion_exit_msg
    end
    super
  end

  def self.count
    @count ||= 0
  end

  def self.add_count
    @count ||=0
    @count += 1
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
      puts "  ok   : #{@count}: #{@title}" 
    else
      puts ''
      puts "\e[31m  FAIL: #{@count}: #{@title}\e[0m"
      puts "  #{@results[2].class}: #{@results[1]}"
      puts ''
    end

  end

end # ======== FeFe_Test

