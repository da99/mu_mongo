require 'ruby2ruby'
require 'parse_tree'
require 'parse_tree_extensions'

module Kernel
    private
       def __method_name_sym__
         caller[0] =~ /`([^']*)'/ and $1.to_sym
       end
end

module Sinatra

    module SSController
    
        def self.registered( app )
            app.helpers Helpers
        end
        
        def controller( raw_controller_name, &new_actions)
          return
            new_controller = SSControllerBase.new(raw_controller_name, &new_actions)
        end # === controller   
        
        module Helpers
        
        end # === module Helpers
        
    end # === module SSController
    
    register SSController

end # === module SSController

class SSControllerBase

    class << self
        def controllers
            @controllers ||= {} # Each value is a Hash.
        end
    end # === class << self
    
    attr_reader :controller_name
    attr_accessor :original_scope
    
    def initialize(raw_controller_name, &new_actions)
        controller_name = raw_controller_name.to_s.strip.to_sym
        # Check if controller was made before.
        if SSControllerBase.controllers.keys.include?(controller_name)
            raise "CONTROLLER ALREADY TAKEN: #{controller_name}" 
        end    
        @controller_name = controller_name
        self.class.controllers[controller_name] = {}        
        create_actions &new_actions
    end
    
    def create_actions(&new_proc)
        self.original_scope = new_proc.binding
        instance_eval &new_proc
    end
    
    def get(*args, &old_proc)
        new_action_name, path, perm_level =  args
        props = generic_props(new_action_name, __method_name_sym__, perm_level, path  )
        
        new_code = %~
            #{props[:http_verb]}( #{props[:path].inspect} ) do |*args|
                describe_action( #{props.inspect} )
                #{ old_proc ? "#{old_proc.to_ruby}.call(*args)" : "render_mab" }
            end
        ~

        eval( new_code , self.original_scope )
    end

    def post(*args, &old_proc)
        raise "PROC IS MISSING FOR CUSTOM :post: #{args.inspect}" unless old_proc
        new_action_name, path, perm_level =  args
        props = generic_props(new_action_name, __method_name_sym__, perm_level,  path  )          
        
        new_code = %~
            #{props[:http_verb]}( #{props[:path].inspect} ) do |*args|
                describe_action( #{props.inspect} )
                #{ old_proc.to_ruby.to_s }.call(*args)
            end
        ~
        eval(  new_code , self.original_scope )
    end

    def put(*args, &old_proc)
        raise "PROC IS MISSING FOR CUSTOM :put: #{args.inspect}" unless old_proc
        new_action_name, path, perm_level =  args
        props =  generic_props(new_action_name, __method_name_sym__, perm_level,  path )                  
        new_code = %~
            #{props[:http_verb]}( #{props[:path].inspect} ) do |*args|
                describe_action( #{props.inspect} )
                #{ old_proc.to_ruby.to_s }.call(*args)
            end
        ~
        eval( new_code , self.original_scope )
    end
    

    
    private # =========================================
           
        
    def generic_props(new_action_name, http_verb, raw_perm_level = nil,  raw_path = nil, new_props = {} )

        perm_level = raw_perm_level || Member::NO_ACCESS       
        path       = raw_path || "/#{controller_name.to_s.underscore}/#{new_action_name}"
        
        # Validate keys for custom props
        if !new_props.empty?
          raise "PROGRAMMER: finish writing this piece of the method."
          valid_prop_keys =[ :action  ,  :path,   :http_verb,  :perm_level, :controller ]
          extra_keys = new_props.keys - valid_prop_keys
          raise "EXTRA/UNKOWN PROPERTIES: #{extra_keys.inspect}" unless extra_keys.empty?
        
          invalid_keys = valid_prop_keys - new_props.keys
          raise "INVALID PROPERTIES: #{invalid_keys.inspect}" unless invalid_keys.empty?
        end      
        
        # Validate verb.
        if ![:get, :put, :post, :delete].include?(http_verb)
            raise "INVALID HTTP VERB: #{http_verb} for #{controller_name.inspect} #{new_action_name.inspect}"
        end
        
        # Validate path.       
        if !path || path.to_s.strip.empty? || path.inspect == '//'
            raise "INVALID PATH: #{path.inspect} for #{controller_name.inspect} #{new_action_name.inspect}"
        end
        
        self.class.controllers.each { |controller_name, actions| 
          actions.each { |action_name, props|
            if props[:path].eql?( path ) && props[:http_verb].eql?( http_verb )
                raise "PATH USED MORE THAN ONCE: \n" +
                "#{controller_name}: #{props[:path].inspect} #{props[:action].inspect} #{props[:http_verb].inspect}\n" +
                "#{self.controller_name}: #{path.inspect} #{new_action_name.inspect} #{http_verb.inspect}"
            end
          }
        }        
        
        # See if action exists.
        self.class.controllers[self.controller_name].each { |action_name, props| 
            if action_name.eql?( new_action_name ) 
                raise "ACTION NAME TAKEN FOR #{self.controller_name}: #{new_action_name}"
            end
            if props[:path].eql?( path ) && props[:http_verb].eql?( http_verb )
                raise "PATH ALREADY USED FOR: #{self.controller_name}: #{path} ==> #{new_action_name.inspect}, #{http_verb.inspect}"
            end
        }
        
        # Send new props.
        SSControllerBase.controllers[controller_name][new_action_name] = {  :action => new_action_name, 
            :path=>path, 
            :http_verb=>http_verb, 
            :perm_level=>perm_level,
            :controller =>controller_name
        }
    end # === def
    

end # === class SSController
