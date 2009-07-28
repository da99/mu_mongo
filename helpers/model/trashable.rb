module Trashable

    def self.included(target)
        target.extend(ClassMethods)
    end
    
    module ClassMethods
        def trashable(*args, &cond_block)
            raise "TRASHABLE IS NOT YET ABLE to deal with custom datasets." if cond_block
            
            name_of_assoc, opts = args

            if opts.is_a?(Hash) && opts[:class]
                opts[:class]
            else
                opts ||= {}
                opts[:class] = name_of_assoc.to_s.singularize.camelize.to_sym
            end
            
            self.one_to_many(*args) { |ds| ds.where(:trashed=>false) }
            self.one_to_many( "all_#{name_of_assoc}".to_sym, opts )
        end
    end # === module ClassMethods

end # === module
