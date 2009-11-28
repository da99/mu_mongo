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
# ========= Create a new FeFe Task Collection
# ===================================================

def FeFe(name_of_class, &blok)

  new_name = "FeFe_#{name_of_class}"

  if Object.const_defined?(new_name)
    return Object.const_get(new_name)
  end

  fefe_class = eval(%~
    class #{new_name}
    end

    #{new_name}
  ~)

  fefe_class.send :include, Butler_Dsl
  fefe_class.send :include, FeFe_Helper_Methods
  fefe_class.send :extend, FeFe_Class_Dsl
  
  # require 'ruby-debug/debugger';
  
  
  fefe_class.instance_eval &blok

end 




# ===================================================
# ======== I present you with: FeFe
# ===================================================


class FeFe_The_French_Maid

  module Prefs
    TASK_DIRECTORY = File.expand_path('~/megauni/helpers/fefe/tasks')
    MY_LIFE        = '~/MyLife'.directory_name
    MY_PREFS       = MY_LIFE.down_directory( 'prefs' )
  end

  attr_reader :orders

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

  def self.require_collection lib
    lib_class_name = str_to_fefe_class_name(lib)
    begin
      unless Object.const_defined?(lib_class_name)
         
#require 'rubygems'; require 'ruby-debug/debugger';
    
        require File.join(Prefs::TASK_DIRECTORY, lib)
      end
      Object.const_get(lib_class_name)
    rescue LoadError
      nil
    end
  end
  
  def self.extract_lib str
    lib, raw_task  = str.split(':')[0,2].map(&:strip)
    task           = raw_task.to_sym
    lib_class      = require_collection lib
    return [lib, task, lib_class]
  end

  def self.str_to_fefe_class_name(str)
    'FeFe_' + str.split('_').map(&:capitalize).join('_')
  end

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


end # === FeFe_The_French_Maid =================================






# ===================================================
# ======== This is used in defining
# ======== a new collection.
# ===================================================


module FeFe_Class_Dsl

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

  class Task_Dsl

    include Demand_Arguments_Dsl
    
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

end # === module




# ===================================================
# ======== Methods available to each
# ======== FeFe task.
# ===================================================


module FeFe_Helper_Methods # ===================================

  include Demand_Arguments_Dsl
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

end # === FeFe_Helper_Methods ==================================



# ===================================================
# ======== FeFe can also be run within 
# ======== other Ruby scripts.
# ===================================================
if $0 == __FILE__ 
  puts
  FeFe_The_French_Maid.new.do_task_from_argv.inspect
  puts
end # ===============================================




