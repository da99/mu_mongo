require 'rubygems'
require 'test/unit'
require 'test/unit/testresult'
require 'term/ansicolor'

class Test::Unit::TestResult
  # Returns a string contain the recorded runs, assertions,
  # failures and errors in this TestResult.
  def to_s
    
    str = []
    str << "#{run_count} tests, "
    str << "#{assertion_count} assertions, "
    str << print_if_non_zero(failure_count, "#{failure_count} failures, ")
    str << print_if_non_zero(error_count, "#{error_count} errors")
    
    str.join
  end

  def print_if_non_zero count, msg
    if count != 0
      Term::ANSIColor.send(:red) { msg }
    else
      msg
    end
  end
end

module Test::Unit
  # Used to fix a minor minitest/unit incompatibility in flexmock
  # AssertionFailedError = Class.new(StandardError)
  
  class TestCase
   
    def self.must(name, &block)
      test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
      defined = instance_method(test_name) rescue false
      raise "#{test_name} is already defined in #{self}" if defined
      if block_given?
        define_method(test_name, &block)
      else
        define_method(test_name) do
          flunk "No implementation provided for #{name}"
        end
      end
    end
 
  end
end

class Model_Member_Test < Test::Unit::TestCase

  must 'be_awesome' do
    assert_equal true, false
  end

end
