#!/usr/bin/env ruby
# -*- ruby -*-

$KCODE == 'UTF8'
require 'rubygems'
require 'open3'

%w{
  string_additions
  symbol_additions
  demand_arguments_dsl
  butler_dsl
}.each { |file|
 require File.expand_path(File.join(File.readlink(__FILE__),'../..','app',file))
}


# ===================================================
# ======== Where the action begins...
# ===================================================

class FeFe_The_French_Maid

  # ======== Constants are in their own module
  # ======== in order to include them in each
  # ======== FeFe class using :include.
  module Prefs
    TASK_DIRECTORY = File.expand_path('~/megauni/helpers/fefe/tasks')
    MY_LIFE        = '~/MyLife'.directory_name
    MY_PREFS       = MY_LIFE.down_directory( 'prefs' )
    PRIMARY_APP    = 'megauni'
  end

  # ======== When FeFe is given a set of orders, they are 
  # ======== parsed and stored here.
  attr_reader :orders

  class << self
    
    def parse_collection_colon_task str
      lib, raw_task  = str.split(':')[0,2].map(&:strip)
      task           = raw_task.to_sym if raw_task
      lib_class      = collection_name_to_class lib
      return [lib, task, lib_class]
    end

    def collection_name_to_class lib
      
      lib_class_name = lib.split('_').map(&:capitalize).join('_')
      
      begin
        
        Object.const_get(lib_class_name)
        
      rescue NameError
        
        file_name = File.join(Prefs::TASK_DIRECTORY, lib )

        begin
          require file_name
        rescue LoadError
          raise LoadError, "Error for #{lib.inspect}: #{$!.message}"
        end



        Object.const_get(lib_class_name)
        
      end
      
    end
    
  end # ======== class << self

  def parse_order *args
    current_order = nil 
    @orders = {:global => [], :task_order => []}
    current_option = nil
    args.flatten.each { |arg|
      if arg[/.+\:.+/] && !arg[' '] # Avoid strings with :, like Git commit messages.
        current_order = arg
        @orders[:task_order] << current_order
        @orders[current_order] = {:global=>[]}
      else
        if current_order
          if arg[/^\-/] 
            current_option = arg.sub(/\-+/,'').strip.to_sym
            @orders[current_order][current_option] ||= ''
          else
            if current_option
              @orders[current_order][current_option] += ' ' + arg
              @orders[current_order][current_option] = @orders[current_order][current_option].strip
            else
              raise ArgumentError, "Option has no key: #{arg.inspect}"
            end
          end
        else
          @orders[:global] << arg
        end
      end
    }
    
    orders
  end

  def run_task_from_argv
    parse_order *(ARGV.map(&:split).flatten)
    if !@orders[:global].empty?
      do_global_tasks
    end

    @orders[:task_order].map { |task_name|
      run_task( task_name, @orders[task_name] )
    }
  end

  def run_task lib_and_task, opts_hash = {}

    lib, task, maid_class = self.class.parse_collection_colon_task(lib_and_task)
    maid                  = maid_class.new
    maid.run_task task, opts_hash
  end


end # === FeFe_The_French_Maid =================================




# ===================================================
# ======== This is used in defining
# ======== a new collection.
# ===================================================

module FeFe
  
  include Demand_Arguments_Dsl
  include Butler_Dsl
  include FeFe_The_French_Maid::Prefs

  def self.included new_class
    new_class.send :extend, Class_Methods
  end

  module Class_Methods

    include Demand_Arguments_Dsl
    
    def tasks
      @tasks ||= {} 
    end

    def describe name, &blok

      demand_sym name

      i = FeFe_Dsl::Task_Dsl.new( name, &blok ).info

      demand_string i.it
      demand_block  i.steps

      tasks[name] = Struct.new( 
                               :name, :it, :options, :steps
                              ).new( name, i.it, i.options, i.steps)

                              define_method "__fefe_task_#{name.bang_to_bang}__", &tasks[name].steps
    end 

  end # ======== Class_Methods
  
 
  def fefe_run task_name, opts={}
    FeFe_The_French_Maid.new.run_task(task_name, opts)
  end


  def run_task task_name, raw_args 
    demand_symbol task_name

    task_info = self.class.tasks[task_name] || self.class.tasks[task_name.bang_to_bang]
    unless task_info
      raise ArgumentError, "Task does not exist: #{task_name.inspect}"
    end
    
    opts = task_info.options
    args = opts.inject([]) { |m,i|
      
      a_name, a_default = i
      
      m <<  (raw_args.has_key?(a_name) && raw_args[a_name]) ||
            (opts.index(i) && raw_args[:global][opts.index(i)] ) ||
            a_default
      
      m
    }

# require 'rubygems'; require 'ruby-debug'; debugger

    send("__fefe_task_#{task_name.bang_to_bang}__", *args)
  end
  
  
  # ===================================================
  # ======== Print methods.
  # ===================================================
  
  def puts_white raw_msg = nil
    if !raw_msg && !block_given?
      raise ArgumentError, "No string or block given."
    end
    if raw_msg && block_given?
      raise ArgumentError, "Both string and block given. You can only use one."
    end

    if raw_msg
      msg = raw_msg.to_s
      puts "\e[37m#{msg}\e[0m"
    else
      puts "\e[37m"
      output = yield
      puts "\e[0m"
      output
    end
    
  end

  def puts_system_in_white *args
  end

  def puts_red raw_msg
    msg = raw_msg.to_s
    puts "\e[31m#{m}\e[0m"
  end
  
  def development?
    ENV['RACK_ENV'] == 'development' || !ENV['RACK_ENV']
  end

  def shell_out(*args, &blok)
    stem          = args.shift
    cmd           = stem % ( args.map { |s| s.to_s.inspect } )

    results, errors = Open3.popen3( cmd ) { |stdin3, stdout3, stderr3|
      [ stdout3.readlines, stderr3.readlines ]
    }
    
    if !errors.empty?

      if block_given?
        return blok.call(results, errors)
      end
      
      puts_red '========  Error from shell_out:  =========  '
      errors.join("\n").each { |err|
        puts_red err
      }      
      
      exit(1)
      
    end
    
    results.join(" ")
  end  

end # ======== FeFe

module FeFe_Dsl

  class Task_Dsl

    include Demand_Arguments_Dsl
    include Butler_Dsl
    
    def initialize task_name, &blok
      @task_name = task_name
      instance_eval &blok
    end

    def info
      @info ||= Struct.new(:it,:steps, :options).new
    end

    def it text
      demand_string text
      info.it = text
    end

    def steps *opts, &blok
      info.options = opts
      info.steps = blok
    end

  end # === Task_Dsl



end # === FeFe_Dsl


# ===================================================
# ======== FeFe can also be run within 
# ======== other Ruby scripts.
# ===================================================
if $0 == __FILE__ 
  puts
  FeFe_The_French_Maid.new.run_task_from_argv.inspect
  puts
end # ===============================================


