require 'sequel'
require 'sequel/extensions/inflector'
require 'sequel/extensions/blank'

require Pow('helpers/db_conn')




class Sequel::Model


  # =========================================================
  #                     Plugins
  # =========================================================  
   
    
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
  #                  CLASS METHODS
  # =========================================================

  def self.filter_params( raw_params, keys )
    keys.inject( {} ) { |m| m[k] = raw_params[k] ; m }
  end
    
  def self.create_it( raw_params, editor )
    raise "You have to define this method."
  end

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
  
  def update_it( raw_params, editor )    
    raise "You have to define this method."
  end # === def  
 

  def require_valid_menu_item!( field_name, raw_error_msg = nil, raw_menu = nil )
    error_msg = ( raw_error_msg || "Invalid menu choice. Contact support." )
    menu      = ( raw_menu || self.class.const_get("VALID_#{field_name.to_s.pluralize.upcase}") )
    self.errors.add( field_name, error_msg ) unless menu.include?( self[field_name] )
  end


  # Sets field to new value using :to_s and :strip
  # Then, adds to :errors if new string is empty.
  def require_string! field_name, raw_error_msg  = nil
    self[field_name] = self[field_name].to_s.strip
    error_msg  = ( raw_error_msg || "A #{field_name} is required." ).strip
    
    self.errors.add( field_name, error_msg ) if self[field_name].empty?
  end


  # Accepts an unlimited number of field names as symbols.
  # If the last item is a STRING, it will be used as the error msg.
  # If a STRING is not used, then a default error message is used.
  def require_at_least_one_string!( *raw_args )

    field_names       = raw_args.select { |i| i.is_a?(Symbol) }
    default_error_msg = raw_args.last.is_a?(String) ?
                           "At least one of these is require: #{field_names.join(', ')}" :
                           raw_args.pop

    all_are_empty  =  field_names.size === field_names.select { |name| self[name].to_s.strip.eql?('') }.size

    self.errors.add( field_names.first, default_error_msg ) if all_are_empty
    
  end 
 
 
end # === model: Sequel::Model -------------------------------------------------





require_these 'models'
