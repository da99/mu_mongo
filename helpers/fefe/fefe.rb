#!/usr/bin/env ruby
# -*- ruby -*-

%w{
  string_additions
  demand_arguments_dsl
  butler_dsl
}.each { |file|
 require File.expand_path(File.join(File.readlink(__FILE__),'../..','app',file))
}

require 'rubygems'


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
  end

  # ======== When FeFe is given a set of orders, they are 
  # ======== parsed and stored here.
  attr_reader :orders

  class << self
    
    def str_to_fefe_class_name(str)
      'FeFe_' + str.split('_').map(&:capitalize).join('_')
    end

    def require_collection lib
      
      lib_class_name = str_to_fefe_class_name(lib)
      
      if Object.const_defined?(lib_class_name)
        return Object.const_get(lib_class_name)
      end
        
      file_name = File.join(Prefs::TASK_DIRECTORY, lib + '.rb')
      
      begin
        code = File.read(file_name)
      rescue Errno::ENOENT
        raise ArgumentError, "File does not exist for #{lib.inspect}: #{file_name}"
      end

      fefe_class = Class.new
      fefe_class.send :extend, FeFe_Dsl::Class_Methods
      fefe_class.send :include, FeFe_Dsl::Instance_Methods
      fefe_class.instance_eval code
      fefe_class
        
    end
    
    def extract_lib str
      lib, raw_task  = str.split(':')[0,2].map(&:strip)
      task           = raw_task.to_sym
      lib_class      = require_collection lib
      return [lib, task, lib_class]
    end
    
  end # ======== class << self

  def parse_order *args
    current_order = nil 
    @orders = {:global => [], :task_order => []}
    args.flatten.each { |arg|
      if arg.include?(':')
        current_order = arg
        @orders[:task_order] << current_order
        @orders[current_order] = []
      elsif current_order
        @orders[current_order] << arg
      else
        @orders[:global] << arg
      end
    }
    orders
  end

  def do_task_from_argv
    parse_order *(ARGV.map(&:split).flatten)
    if !@orders[:global].empty?
      do_global_tasks
    end

    @orders[:task_order].map { |task_name|
      do_task( task_name, *@orders[task_name] )
    }
  end

  def do_task lib_and_task, *args
    lib, task, maid_class = self.class.extract_lib(lib_and_task)
    maid                  = maid_class.new
    maid.run_task task, *args
  end


end # === FeFe_The_French_Maid =================================




# ===================================================
# ======== This is used in defining
# ======== a new collection.
# ===================================================


module FeFe_Dsl

  module Class_Methods
    
    include Demand_Arguments_Dsl

    def tasks
      @tasks ||= {} 
    end

    def describe name, &blok

      demand_sym name

      i = Task_Dsl.new( name, &blok ).info

      demand_string i.it
      demand_block  i.steps

      tasks[name] = Struct.new( 
                               :name, :it, :options, :steps
                              ).new( name, i.it, i.options, i.steps)

      define_method "__fefe_task_#{name}__", &tasks[name].steps
    end
    
  end # ======== Class_Methods

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

  module Instance_Methods
    
    include Demand_Arguments_Dsl
    include Butler_Dsl
    include FeFe_The_French_Maid::Prefs
 
    def fefe_run task_name, *args
      FeFe_The_French_Maid.do_task(task_name, *args)
    end

    def run_task task_name, *raw_args
      task_info = self.class.tasks[task_name]
      opts = task_info.options
      args = opts.inject([]) { |m,i|
        a_name, a_default = i
        val               = raw_args[ opts.index(i) || opts.size ]
        m << (val || a_default)
        m
      }
      # require 'rubygems'; require 'ruby-debug/debugger';

      send("__fefe_task_#{task_name}__", *args)
    end

  end # === Instance_Methods

end # === module


# ===================================================
# ======== FeFe can also be run within 
# ======== other Ruby scripts.
# ===================================================
if $0 == __FILE__ 
  puts
  FeFe_The_French_Maid.new.do_task_from_argv.inspect
  puts
end # ===============================================


