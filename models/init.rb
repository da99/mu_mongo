require 'sequel'
require 'sequel/extensions/inflector'
require 'sequel/extensions/blank'

require_these 'helpers/model'


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




