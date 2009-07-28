module NormalizeData

    def self.included(target_class)
    
        target_class.before_validation do
            strip_and_utc_everything
        end
        
    end # === def self.included
    
    module ClassMethods
    end # === module
    
  # 
  #  Use model constant PROTECT_WHITESPACE to specify
  #  an array of fields where whitespace (newlines and tabs) 
  #  should be protected.
  # 
  def strip_and_utc_everything
  
    schema = self.class.db_schema
        
    # --- PROCESS NEW VALUES
    new_vals = self.class.columns.inject({}) {|m,col| 
                  k , v  = col, self.send(col)
                  skema =  self.class.db_schema[k]
                  
                  # -------- STRIP STRINGS
                  if v.respond_to?(:strip)
                    if self.class.const_defined?(:PROTECT_WHITESPACE) && self.class::PROTECT_WHITESPACE.include?(k)
                      m[k] = Wash.plaintext(v, :include_spaces, :include_tabs) 
                    else
                      m[k] = Wash.plaintext(v) 
                    end
                    m[k] = nil if m[k].blank? && skema[:allow_null]
                  end
                  
                  # ---------- UTC-ify DateTimes
                  # Note: If value is originally a String, then 
                  #  String#to_sequel_time is used to typecase it 
                  #  before it gets here.
                  #        
                  if v.respond_to?(:utc?)
                        m[k] = v.utc?  ?
                                   v :
                                   v.utc;
                  end
                  
                  # ---------------- RETURN
                  m
    }
    
    set(new_vals)
    
  end # ------ strip_and_utc_everything -----------  
   

end # === NormalizeModelData
