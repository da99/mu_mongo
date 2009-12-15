module AncestorModels

    def self.included(target_class)
        target_class.extend ClassMethods
    end
    
    def ancestor_records
        all_ancestors = []
        return all_ancestors if !self.class.parent_model?
        self.class.ancestor_models.map { |parent_mod| 
            self.send(parent_mod.name.underscore)
        }
    end # === def
    
    module ClassMethods
          # =========================================================
          #                      CLASS METHODS
          # =========================================================
          
          def parent_model?
            const_defined?(:PARENT_MODEL)
          end

          # Valid options:
          #   :include_parent_model
          def name_underscored( *opts )

            valid_opts = [:include_parent_model]
            invalid_opts = (opts - valid_opts)
            raise ArgumentError, "Invalid options." if !invalid_opts.empty?
            
            @name_underscored ||= begin
              if self.const_defined?(:PARENT_MODEL) && !opts.include?(:include_parent_model)
                prefix = Kernel.const_get( self.const_defined?(:PARENT_MODEL) ).name.underscore + '_'
                self.name.underscore.sub( prefix, '' )
              else
                self.name.underscore
              end
            end
          end # === self.name_underscored
          
        def ancestor_models
            
            return [] if !self.const_defined?(:PARENT_MODEL)
            return @family_models if @family_models
            @family_models = [ ]
            
            current_model_name = self::PARENT_MODEL
            while( current_model_name ) do
              current_model = Object.const_get(current_model_name)
              @family_models <<  current_model
              current_model =  current_model.const_defined?(:PARENT_MODEL) ? 
                               Kernel.const_get( current_model.const_get(:PARENT_MODEL) ) :
                               nil
              current_model_name = current_model ? current_model.name.to_sym : nil
            end # === while
            
            @family_models

        end # === def ancestor_models
          
    end # === module ClassMethods


end # === module

