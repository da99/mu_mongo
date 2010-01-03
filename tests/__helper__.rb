ENV['RACK_ENV'] = 'test'


require 'rubygems'
require 'test/unit'
require 'test/unit/testresult'
require 'test/unit/testcase'
require 'term/ansicolor'
require 'helpers/app/Color_Puts'
require 'megauni'

include Color_Puts

puts_white " ===================================== "

at_exit do
  puts ''
end

class Test::Unit::TestResult
  # Returns a string contain the recorded runs, assertions,
  # failures and errors in this TestResult.
  def to_s_with_colors
    
    str = []
    str << "#{run_count} tests, "
    str << "#{assertion_count} assertions, "
    str << colorize_result(failure_count, "#{failure_count} failures, ")
    str << colorize_result(error_count, "#{error_count} errors, ")
    
    test_pass_count ||= run_count - failure_count - error_count

    txt = case test_pass_count
          when 0 
            'None passed '
          when 1
            '1 pass '
          when run_count
            'All pass :) '
          else
            "#{test_pass_count} passes "
          end

    str << colorize_green( txt )
    
    str.join
  end
  alias_method :to_s_wo_colors, :to_s
  alias_method :to_s, :to_s_with_colors

  def colorize_result count, msg
    if count != 0
      colorize_red msg
    else
      colorize_white msg
    end
  end
end


class Test::Unit::TestCase
  
  # Used to fix a minor minitest/unit incompatibility in flexmock
  # AssertionFailedError = Class.new(StandardError)
  
  def self.must_methods
    @must_methods ||= {}
  end

  def self.must(name, &block)
    test_name = "test_#{name.gsub(/[^a-z0-9\_]+/i,'_')}".to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
      must_methods[test_name] = caller[0]
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end

  # Since I am not smart enough to figure out how to right a 
  # custom Test::Unit::UI to catch empty tests, the following 
  # hack will do.
  # The following will raise a RuntimeError if an empty test, ( do...end ),
  # is found. If there was an error or failure, it will *not*
  # raise a RuntimeError.
  def run_and_raise_on_empty_test *args, &blok
    
    get_vals = lambda { |runner| [ runner.assertion_count, runner.error_count, runner.failure_count ] }
    orig     = get_vals.call(args.first)
    result   = run_wo_raise_on_empty_test(*args, &blok)
    latest   = get_vals.call(args.first)

    if orig == latest  
      msg = "Empty test: :#{method_name} in file: #{self.class.must_methods[method_name.to_sym]}"
      raise msg
    end
    
    result 
  end
  alias_method :run_wo_raise_on_empty_test, :run
  alias_method :run, :run_and_raise_on_empty_test
  
  # === Custom Helpers ===

  def self.admin_mem
    @admin_mem ||= Member.by_id("member-admin-member-1")
  end
  
  def self.regular_mem
    @regular_mem ||= [1,2,3].map { |i| Member.by_id("member-regular-member-#{i}") }
  end
  
  3.times do |i|
    eval %~
      def regular_mem_#{i}
        self.class.regular_members[#{i}-1]
      end
      def regular_username_#{i}
        self.class.regular_members[#{i}-1].data.lives.first.last[:username]
      end
      def regular_password_#{i}
        'regular-password'
      end
    ~
  end

  def admin_mem
    self.class.admin_mem
  end

  def admin_username
    self.class.admin_mem.data.lives.first.last[:username]
  end

  def admin_password
    'member-admin-member-1'
  end

  def utc_string
    Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')
  end

  def chop_last_2(str)
    if not str.is_a?(String)
      raise ArgumentError, "#{str.inspect} needs to be a String."
    end
    str[0, str.size - 2]
  end

end
