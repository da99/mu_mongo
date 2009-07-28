require 'sequel'
require 'sequel/extensions/inflector'
require 'sequel/extensions/blank'

require_these 'helpers/model'


class Sequel::Dataset
  def first_or_raise( *opts, &blok )
    record = first( *opts, &blok )
    if !record
        raise Sequel::Model::NoRecordFound
    end
    record
  end   
end # === Sequel::Dataset

class Sequel::Model

  # =========================================================
  #                     Plugins
  # =========================================================  
  Sequel::Model.plugin :hook_class_methods 
  
  # =========================================================
  #                     Error Constants
  # =========================================================    
  class NoRecordFound < RuntimeError;  end



  # =========================================================
  #                      Attributes
  # =========================================================  
  self.raise_on_save_failure = true
  self.raise_on_typecast_failure  = false

  # =========================================================
  #                        OPTIONS
  # =========================================================  

  # =========================================================
  #                      Functionality
  # =========================================================  
  
  include NormalizeData  
  include InitDefaultValues
  include AncestorModels
  include EditorGuard
  include ValidateIt
  include Trashable
  include TimestampIt

  # =========================================================
  #                  CLASS INSTANCE METHODS
  # =========================================================
  
  # =========================================================
  # From: http://snippets.dzone.com/posts/show/2992
  # Note: Don't cache subclasses because new classes may be
  # defined after the first call to this method is executed.
  # =========================================================
  def self.all_subclasses
    all_subclasses = []
    ObjectSpace.each_object(Class) { |c|
              next unless c.ancestors.include?(self) and (c != self)
              all_subclasses << c
    }
    all_subclasses 
  end # ---- self.all_subclasses --------------------
  

  
  # =========================================================
  #                  PUBLIC INSTANCE METHODS
  # =========================================================
  def dev_log(msg)
    puts(msg) if Pow!.to_s =~ /\/home\/da01\// && [:development, "development"].include?(Sinatra::Application.options.environment)
  end

 
end # === model: Sequel::Model -------------------------------------------------


__END__

  def owner_tz(attr_name)
    return nil unless self.respond_to?(attr_name) && self.respond_to?(:owner)
    self.owner.local_time_as_string( self[attr_name.to_sym] )
  end
  
  #
  # Returns info. about the table's indexes 
  # using SHOW INDEX
  # 
  # Returns: Hash. 
  #   - :symbols -  All keys are table names as symbols along with two
  #               special keys (see following).  Columns without indexes are NOT
  #               included.
  #   - :uniques - Array. Each value is another array containing symbols of 
  #                       table names.
  #   - :indexes - Hash. Keys are index names and each value is an Array
  #                       of table names.
  # 
  # Example:
  #     Tagging.db_indexes => 
  #         { 
  #             :id => {:unique => Boolean },
  #             :owner_username => {:unique => Boolean }
  #               
  #            :model_class_name => {:unique => Boolean or Nil}
  #
  #                 >> All other table names are NOT included. Only ones with indexes. <<
  #
  #             :uniques => [  [:owner_username, :model_class_name ] ]
  #             :indexes => { :taggings_owner_username_model_class_name_model_id_index => [:owner_username, :model_class_name ]  }
  #         }
  #
  def self.db_indexes
    indexes = SurferDB.conn.fetch('SHOW INDEX FROM ? ' , self.table_name ).inject({ :uniques=>[], :indexes=>{} }) do |m, row|
                      col_name = row[:Column_name].to_sym
                      m[ col_name ] ||= {}
                      uniq_ness =  row[:Non_unique].zero? ? true : false
                      
                      if row[:Column_name] == row[:Key_name] || row[:Key_name] == 'PRIMARY'
                        m[ col_name ][:unique] = uniq_ness  
                      end
                      
                      m[:indexes][row[:Key_name]] ||= []
                      m[:indexes][row[:Key_name]] << col_name
                      
                      if uniq_ness
                        m[ :uniques ] << row[:Key_name]
                      end
                      
                      
                      m
                    end
    indexes[:uniques].map! {|key_name| indexes[:indexes][key_name] }     
    
    indexes               
  end    



  # ====================================================================
  # This is meant to be used with fields that are meant to be
  # a String or Fixnum.
  # ====================================================================
  def zero_or_blank_as_string?(field_name)
    self[field_name].to_i.zero? || blank_as_stirng?(field_name)
  end

  # ====================================================================
  # See if a field is an empty string if turned into string?
  # I used this instead of :blank?
  # ====================================================================
  def blank_as_string?(field_name)
    return true if self[field_name].nil?
    return true if self[field_name].to_s.strip.empty?
    false
  end


#class String
#    alias :to_sequel_time_wo_utc :to_sequel_time
#    
#    #
#    # Overrides the original method that is used to 
#    # typecast values when Sequel retrieves them from
#    # the database.
#    #
#    def to_sequel_time
#      # return nil if self == '0000-00-00 00:00:00'
#      return "#{self} UTC".to_sequel_time_wo_utc if (self.upcase)['UTC'].nil?
#      self.to_sequel_time_wo_utc
#    end # -------------- to_sequel_time
#  
#end # ------ String -------------------------------------


#class Sequel::Schema::Generator 
  ##alias :column_wo_default_null_false :column
  
  ###
  ### Overrides the original method from Sequel.
  ### Sets null=>false when a column is made.
  ### If column has a type == :datetime, then null=>true 
  ###
  ##def column(name, type, opts = {})
    ##type_as_sym = type.to_s.to_sym # :type can sometimes be a symbol, a class (Integer), or who knows what.
    ##null_it = ( type_as_sym == :datetime) ? true : false
    ##column_wo_default_null_false( name, type, {:null=>null_it}.merge(opts) )
  ##end
  
#end # -------- Sequel::Schema::Generator 
