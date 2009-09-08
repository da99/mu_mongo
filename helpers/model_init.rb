require 'sequel'
require 'sequel/extensions/inflector'
require 'sequel/extensions/blank'


class Sequel::Model


  # =========================================================
  #                     Plugins
  # =========================================================  
   
    
  # =========================================================
  #                     Error Constants
  # =========================================================    
  class NoRecordFound < StandardError; end
  class UnauthorizedEditor < StandardError; end
  

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
  
  def self.__setter_method_name__(fn)
    "__set_and_validate_#{fn}__"
  end

  # 
  # This function is to create setters. You may be asking why
  # not just do it directly with "def some_column=" ?
  # Well, if you happen to use def with a misspelled column name,
  # or you re-write an existing setter by mistake.
  # This method extra guarantee to catch those mistakes.
  #
  # Options:
  #   :not_a_column - Allow method to be used even though field does not exist.
  #            Example: :password used in Member even thought :password is not a field.
  #  
  def self.def_setter( fn, *args, &meth )
    meth_name= __setter_method_name__(fn)
    
    invalid_args = args - [:not_a_column]
    if !invalid_args.empty?
      raise ArgumentError, invalid_args.inspect 
    end
    
    invalid_column = !columns.include?(fn) && !args.include?(:not_a_column)
    if invalid_column
      raise "Column, #{fn.inspect}, does not exist. (From #{__previous_line__})" 
    end
   
    meth_exists = new.respond_to?(meth_name)
    if meth_exists
      raise "Set method for #{fn.inspect} already defined. (From #{__previous_line__})" 
    end

    define_method(meth_name, &meth)

  end # === def_setter
  
  def self.def_create( &meth )
    use_method_once
    
    new_meth = :__create_
    
    define_method( new_meth, &meth )
   
    class << self
      def editor_create editor, raw_vals
        n = new
        n.__save__(:create, editor, raw_vals) 
      end
    end
   
  end

  def self.def_update( &meth )
    use_method_once 
    
    new_meth = :__update__
    define_method( new_meth, &meth )
    def editor_update editor, raw_vals
      raise "This record is still new. :update can not be used." if new?
      __save__(:update, editor, raw_vals)
    end
  end

  [:create, :update, :save].each do |meth_name|
    eval( %!
      def self.def_after_#{meth_name} &meth
        use_method_once
        define_method( :after_#{meth_name}, &meth )
      end
    !)
  end
 

  def self.trashable(*args, &cond_block)
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
  #                          HOOKS
  # =========================================================    
  
  # =================== NO HOOKS ARE USED. SEE :define_alter.
  
  # =========================================================
  #                  PUBLIC INSTANCE METHODS
  # =========================================================  
   
  
  def human_field_name( col )
    col.to_s.gsub('_', ' ')
  end
  
  attr_accessor :current_editor, :raw_data
  
  def raw_data 
    @raw_data ||= {}
  end
  
  def allow_any_stranger
    @editor_permission_level = :STRANGER
  end
  
  def allow_only( *levels)
    raise "Only permission levels allowed. No blocks." if block_given?
    allow_at_least(*levels)
  end
  
  def allow_at_least(*levels, &blok)
    
    raise "Only a permission level or block allowed, but not both." if !levels.empty? && blok
    raise "Permission level or block are require." if levels.empty? && !blok
    
    do_it = if !raw_data[:EDITOR]
              nil 
            elsif levels.empty?
              instance_eval( &blok )
            elsif levels.include?(Member::STRANGER)
              raise ":STRANGER not allowed in this method. Try :allow_any_stranger." 
            else
              levels.detect { |lev|
                raw_data[:EDITOR] && raw_data[:EDITOR].has_power_of?(levels.first)
              }
            end
    
    raise( UnauthorizedEditor, raw_data[:EDITOR].inspect ) if !do_it
    @editor_permission_level = perm_level || blok
  end
  
  
  def __save__(target_action, editor, raw_vals, &meth)
  
    self.raw_data = raw_vals
    self.current_editor = editor
    
    send "__#{target_action}__"
    
    # Make sure a permission level was set to protect 
    # against unauthorized editors.
    if !@editor_permission_level
      raise("Editor permission level not set for: #{self.class}.#{target_action}")  
    else
      @editor_permission_level = nil
    end
    
    raise ValidationFailed, errors.full_messages if !errors.empty?
    save(:changed=>true)
    
  end # === def validate
  
  def require_columns *raw_keys
    raw_params = raw_data
    keys = raw_keys.flatten
    keys.each { |k| 
      begin
        send( self.class.__setter_method_name__(k), raw_params )
      rescue NoMethodError
      
        raise "Invalid field name" if !self.class.db_schema[k]
        
        if self.class.db_schema[k][:type] == :integer
          if !raw_params.has_key?(k) || self[k].nil? || self[k].to_i < 1
            self.errors[k] << "#{human_field_name(col).capitalize} is required."
          else 
            self[k] = raw_params[k]
          end
        else
          new_val = raw_params[k].to_s.strip.empty?
          if !raw_params.has_key?(k) || raw_params[k].nil? || new_val.empty?
            self.errors[k] << "#{human_field_name(k).capitalize} is required."
          else
            self[k] = new_val
          end
        end
        
      end # === if/else 
    }
    self
  end # === def
  
  
  def optional_columns *raw_keys
    raw_params = raw_data
    keys = raw_keys.flatten
    keys.each { |k| 
      next if raw_params.has_key?( k )
      
      begin
        send __setter_method_name__(k), raw_params
      catch NoMethodError
        if self.class.db_schema[k][:type] == :integer
          self[k] = if raw_params[k].nil?
                       nil
                    else
                      raw_params[k].to_i
                    end
        else
          self[k] = if raw_params[k].nil?
                       nil
                    else
                      raw_params[k].to_s.strip
                    end
        end          
      end

    }
    self
  end # === def


  def require_valid_menu_item!( field_name, raw_error_msg = nil, raw_menu = nil )
    error_msg = ( raw_error_msg || "Invalid menu choice. Contact support." )
    menu      = ( raw_menu || self.class.const_get("VALID_#{field_name.to_s.pluralize.upcase}") )
    self.errors.add( field_name, error_msg ) unless menu.include?( self[field_name] )
  end


  def require_assoc! assoc_name, raw_error_msg  = nil
    field_name = "#{assoc_name}_id".to_sym
    self[field_name] = self[field_name].to_i
    if self[field_name].zero?
      self.errors.add( field_name , "No id for #{assoc_name} specified." ) 
    end
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


