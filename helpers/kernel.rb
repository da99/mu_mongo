require 'pow'

if !Pow('~').is_a?(Pow::Directory)
  module Pow

    class Base
      def self.open(*paths, &block) #:nodoc:
        paths.collect! {|path| path.to_s}
        
        raw_path = ::File.join(paths)
        expanded_path = ::File.expand_path(raw_path)
        klass = nil
        
        path = [raw_path, expanded_path].detect { |loc|
            klass = if ::File.directory?(loc)
              Directory
            elsif ::File.file?(loc)
              File
            end
        } 
        
        path ||= raw_path
        klass ||= self
    
        klass.new(path, &block)
      
      end
    end
  end
end # == if


def require_these( dir )
  Dir[ File.join(dir, '*.rb') ].each { |f| require Pow(f).to_s.sub(/.\rb$/, '') }
end

def read_if_file(f)
  err_file = Pow(f)
  err_file.file? ? 
    err_file.read :
    nil
end

module Kernel
private
   def __previous_method_name__
     caller[1] =~ /`([^']*)'/ && $1.to_sym
   end
   
   def __previous_line__
    caller[1].sub(File.dirname(File.expand_path('.')), '')
   end
   
   def at_least_something?( unknown )
   
    return false if !unknown
   
    if unknown.respond_to?(:strip)
      stripped = unknown.strip
      return stripped if !stripped.empty?
    elsif unknown.is_a?(Numeric)
      return unknown if unknown > 0 
    else
      unknown
    end
    
    false
   end
end

