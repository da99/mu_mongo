require File.expand_path('~/megauni/helpers/app/string_additions.rb')

module Demand_Arguments_Dsl

    attr_accessor :assertion_exit_msg

    def on_assertion_exit( &new_proc )
      if !@on_assertion_exit 
        @on_assertion_exit = proc {
          if !ENV['RACK_ENV'] && File.expand_path('~/')['home/da01']
            puts assertion_exit_msg
            exit(1)
          else
            raise ArgumentError, assertion_exit_msg
          end
        }
      end
      if block_given?
        @on_assertion_exit = new_proc
      end
      @on_assertion_exit
    end

    def read_around_line raw_file, raw_line, surround = 2

      file         = demand_file_exists(raw_file)
      line         = raw_line.to_i

      file_content = File.read(file)
      starting     = line - surround
      ending       = line + surround
      c_line = line - surround
      file_content.split("\n")[starting..ending].map { |l|
        c_line += 1
        if c_line == line 
          "\e[31m#{c_line}: #{l}\e[0m"
        else
          "#{c_line}: #{l}"
        end
      }.join("\n")
    end

    # def file_and_line arr
# 
#       include_gems = Object.const_defined?(:Gem)
# 
#       caller_entry = arr.detect { |l|
#         first_pass = !l[self.class.demand_arguments_parent_class_file}] &&
#                      !l[__FILE__]
#         if !first_pass && include_gems
#           Gem.all_load_paths.detect { |g_path|
#             !l[g_path]
#           }
#         else
#           first_pass
#         end
#       } || arr.first

    #   f_and_l = caller_entry.split(':')
      # f_and_l[0,2]
    # end

    def print_and_exit msg, shift_entries = 2
      msg ||= "Unknown assertion error."
      @using_gems ||= Object.const_defined?(:Gem)
      entries = caller[shift_entries,caller.size].select { |l|
        if @using_gems
          !Gem.all_load_paths.detect { |lp|
            l[lp]
          }
        else
          true
        end
      }
      
      seirtne = entries.reverse

      seirtne.each { |l|
        @assertion_exit_msg ||=''
        
        file, line = l.split(':')[0,2]

        @assertion_exit_msg += %~
#{'*' * msg.size}
#{file}
#{'*' * msg.size}
#{read_around_line(file, line)}
#{'*' * msg.size}
~
        
      }

      @assertion_exit_msg = @assertion_exit_msg + %~

\e[31m
#{' =' * (msg.size/2)}        
#{msg}
#{' =' * (msg.size/2)}  
\e[0m

      ~
      on_assertion_exit.call

    end
    
    def demand_to_be_done
      print_and_exit "Please implement this part of the program.", 1
    end

    def demand_binding b
      if !b.is_a?(Binding)
        print_and_exit "Binding required."
      end
      b
    end

    def demand_string s
      if !s.is_a?(String)
        print_and_exit "String is required."
      end
      s
    end

    def demand_sym sym
      if !sym.is_a?(Symbol)
        print_and_exit "Symbol is required. #{sym.class} objects are not allowed."
      end
      sym
    end

    def demand_block blok
      return blok if blok.is_a? Proc
      print_and_exit "This needs to be a Proc/lambda: #{blok.inspect}"
    end

    def demand_block_given b
      demand_binding b
      if !eval("block_given?", b)
        print_and_exit "Block required."
      end
    end

    def demand_no_block_given b
      demand_binding b
      blok_given = eval("block_given?", b)
      if blok_given
        print_and_exit "No block allowed."
      end
    end
      
    def demand_hash arg, &blok
      if !arg.is_a?(Hash)
        print_and_exit( "Not a hash: #{arg.inspect}" )
      end
      
      if block_given?
        h_v = HashArgumentDSL.new
        h_v.instance_eval &blok
        invalid = arg.keys - h_v.keys
        missing = h_v.demand - args.keys
        if !invalid.empty?
          print_and_exit "Invalid keys: #{invalid.join(', ')}"
        end
        if !missing.empty?
          print_and_exit "Missing keys: #{invalid.join(', ')}"
        end
      end
      arg
    end

    def demand_directory_exists raw_arg
      d= raw_arg.directory_name
      return d if d
      print_and_exit "Not an existing directory: #{raw_arg.inspect}"
    end

    def demand_file_exists raw_file
      f = raw_file.file_name
      return f if f
      print_and_exit "Not an existing file: #{raw_file.inspect}"
    end

    def demand_exists_on_filesystem raw_path
      f = raw_path.file_system_name
      return f if f
      print_and_exit "File or directory must exist: #{raw_path}"
    end

    def demand_sym_link_matches &blok
      demand_block blok
      dsl = Generic_Dsl.new(:from=>:string, :to=>:string, &blok)
      demand_exists_on_filesystem dsl.from
      if File.exists?(dsl.to.file_system_name)
        if File.readlink(dsl.to.file_system_name) != dsl.from.file_system_name
          print_and_exit("Files are not the same: #{dsl.from}, #{dsl.to}")
        end
      else
        print_and_exit "Does not exist: #{dsl.to}"
      end
    end

end # === Demand_Arguments_Dsl

class Generic_Dsl

  attr_reader :cache, :fields, :options

  def initialize opts, &blok
    @options = opts.symbolize_keys
    @fields = @options.keys
    @cache = {}
    @fields.each { |f|
      @cache[f] = []
    }
    instance_eval &blok
  end

  def method_missing meth_name, *args

    return(super) if !@fields.include?(meth_name)

    case args.size
      when 0
        cache[meth_name]
      else
        cache[meth_name] ||= []
        case @options[meth_name]
          when :string
            cache[meth_name] = args.first.to_s
          when :array
            cache[meth_name] << args
          when :object
            cache[meth_name] = args.first
          else
            raise ArgumentError, "Unknown: #{@options[meth_name]}"
        end
    end

  end

end # ==== Generic_Dsl

class HashArgumentDSL
    def keys
      [demand, allow].flatten
    end
    def demand *args
      @demand ||= []
      @demand = (@demand + args).flatten
      @demand
    end 
    def allow *args
      @allow ||= []
      @allow = (@allow + args).flatten
      @allow
    end 
end # === HashArgumentDSL

