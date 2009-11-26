

module Kernel

   private # =========================================

   def __previous_method_name__
     caller[1] =~ /`([^']*)'/ && $1.to_sym
   end

   def __method_name__
     caller[0] =~ /`([^']*)'/ && $1.to_sym
   end

   def __previous_line__
    caller[1].sub(file.dirname(file.expand_path('.')), '')
   end
   
   def require_hash_keys h, *k_arr
    valid   = k_arr.flatten
    invalid = h.keys - valid
    if !invalid.empty?
      raise ArgumentError, "Invalid keys in #{__previous_method_name__}: #{invalid.inspect}"
    end

    true
   end

   def at_least_something?( unknown )
   
    return false if !unknown
   
    if unknown.respond_to?(:strip)
      stripped = unknown.strip
      return stripped if !stripped.empty?
    elsif unknown.is_a?(numeric)
      return unknown if unknown > 0 
    else
      unknown
    end
    
    false
   end
end

# class Object
# 
#   private
#   def use_method_once
#     meth = __previous_method_name__ 
#     @methods_only_once ||= []
#     raise "#{meth} can only be used once." if @methods_only_once.include?(meth)
#     @methods_only_once << meth
#   end
# 
# end

