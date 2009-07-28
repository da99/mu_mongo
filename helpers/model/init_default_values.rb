module InitDefaultValues

  def initialize(*args)
    original_super = super(*args) 
    return original_super if !new?

    # ========== Set default values for columns.
    pg_default_str_pattern  = /\'([^\']{0,})'\:\:.{1,}/
    primary_key_pattern     =  /\_seq|\:\:/
      
    columns.each { |col|
      col_schema      = self.class.db_schema[col]
      default_value   = col_schema[:default]

      if self[col].nil? && default_value != nil
      
          is_int          = col_schema[:type].eql?(:integer) && default_value !~ primary_key_pattern
          is_string       = col_schema[:type].eql?(:string) 
          is_bool         = col_schema[:type].eql?(:boolean)
            
        self[col]  = default_value.to_i  if is_int
        self[col]  = default_value         if is_string
        self[col]  = default_value         if is_bool 
        
        # ======================================================================
        # Handle special "ruby-pg" case if String and default value is in form
        # of: "'UTC'::varying char type"
        # ======================================================================
        if is_string && self[col] =~ pg_default_str_pattern
          self[col] = $1
        end
        # ======================================================================
      end
    }

    original_super
  end #=== initialize


end # === module
