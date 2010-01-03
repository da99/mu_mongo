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
    str << colorize_result(error_count, "#{error_count} errors")
    
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

  def self.admin_user
    @admin ||= begin
                 mem_id = CouchDB_CONN.GET_by_view(:member_usernames, {:limit=>1})[:rows].first[:value]
                 Member.by_id(mem_id)
               end
  end
  
  def self.regular_user
    @regular_user ||= begin
                        mem_id = CouchDB_CONN.GET_by_view(:member_usernames, {:limit=>2})[:rows].last[:value]
                        Member.by_id(mem_id)
                      end
  end

  def admin_user
    self.class.admin_user
  end

  def regular_user
    self.class.regular_user
  end

end
