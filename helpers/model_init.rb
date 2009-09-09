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
  
  def self.allow_creator( *levels, &blok ) 
    add_perm_for_editor(:create, levels, &blok)
  end

  def self.allow_updator( *levels, &blok )
    add_perm_for_editor(:update, levels, &blok)
  end 

  def self.add_perm_for_editor( action, levels, &blok)
    raise ArgumentError, "Block required for #{action.inspect}" if !block_given?
    raise ArgumentError, "Invalid action type: #{action.inspect}" if ![:create, :update].include?(action)
    raise ArgumentError, "nil not allowed among other levels" if levels.length > 1 && levels.include?(nil)
    @editor_perms ||= {:create=>{}, :update=>{} }  
    levels.each do |raw_lev|
      lev = raw_lev.nil? ? :STRANGER : raw_lev
      raise "#{lev.inspect} already used for creator." if @editor_perms[action].has_key?(lev)
      @editor_perms[action][lev] = blok
    end
  end

  def self.validator col, &blok
    define_method "validator_for_#{col}", &blok
  end

  def self.editor_permissions
    @editor_perms
  end

  def self.creator editor, raw_vals
    n = new
    n.call_editor_validator(editor, raw_vals)
    n.created_at = Time.now.utc if n.respond_to?(:created_at)
    n._save_
  end
  
  def self.updator editor, raw_vals
    rec = self[:id=>raw_vals]
    raise NoRecordFound, "Try again." if !rec
    n.call_editor_validator(editor, raw_vals)
    rec.updated_at = Time.now.utc if rec.respond_to?(:updated_at)
    rec._save_
  end

  def call_editor_validator(editor, raw_vals)
    self.current_editor = editor
    self.raw_data = raw_vals
    action = new? ? :create : :update
    action_perms = self.class.editor_permissions[action]
    level_found = begin
      levels = action_perms.keys
      levels.detect { |lev|
        if !current_editor
          lev == :STRANGER
        else
          if current_editor.has_power_of?(lev)
            lev
          else respond_to?(lev) 
            editor_list = [ send(lev) ].flatten 
            editor_list.detect { |ed| 
              ed.has_power_of?(current_editor)
            }
          end
        end
      }
    end
    raise( UnauthorizedEditor, current_editor.inspect ) if !level_found
    self.valid_editor_found = true
    instance_eval( &action_perms[level_found] )
    raise_if_invalid

    self.current_editor
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
  
  
  # =========================================================
  #                  PUBLIC INSTANCE METHODS
  # =========================================================  
   
  attr_accessor :current_editor, :raw_data, :valid_editor_found
  
  def raw_data 
    @raw_data ||= {}
  end

  def valid_editor_found=(new_val)
    if @valid_editor_found
      raise "Valid editor already used: #{valid_editor_found.inspect}" 
    end
    @valid_editor_found = new_val
  end

  def human_field_name( col )
    col.to_s.gsub('_', ' ')
  end
  
  def allow_editor( level, &blok )
    return if self.valid_editor_found
    raise ArgumentError, "Block required." if !block_given?
    level = :STRANGER if level.nil?
    if (!current_editor && level === :STRANGER) || current_editor.has_power_of?(level)
      self.valid_editor_found = true
      yield
    end
  end
  
  def raise_if_invalid
    raise Sequel::ValidationFailed, errors.full_messages if !errors.full_messages.empty?
  end

  def _save_
     
    begin
      save(:changed=>true)
    
    rescue Sequel::DatabaseError
      raise if $!.message !~ /duplicate key value violates unique constraint \"([a-z0-9\_\-]+)\"/i
      seq = $1
      col = seq.sub(self.class.table_name.to_s + '_', '').sub(/_key$/, '').to_sym
      raise  if !self.class.db_schema[col.to_sym]
      self.errors.add col, "is already taken. Please choose another one."
      raise_if_invalid

    rescue
      raise

    end
    
  end # === def validate

  def require_column col
    require_columns col
  end

  def require_columns *raw_keys
    raw_params = raw_data
    keys = raw_keys.flatten
    keys.each { |k| 
      begin
        send( "validator_for_#{k}"  )
      rescue NoMethodError
     
        is_column = !self.class.db_schema[k] 

        raise "Invalid field name: #{k.inspect}" if is_column
        case self.class.db_schema[k][:type]

          when :integer
            if !raw_params.has_key?(k) || self[k].nil? || self[k].to_i < 1
              self.errors.add k, "is required."
            else 
              self[k] = raw_params[k]
            end

          else
            new_val = raw_params[k].to_s.strip.empty?
            if !raw_params.has_key?(k) || raw_params[k].nil? || new_val.empty? || new_val.to_s.strip.empty?
              self.errors.add k, "is required."
            else
              self[k] = new_val
            end
        end # === case
        
      end # === if/else 
    }
    self
  end # === def
  
  def require_columns_if_exist *raw_keys
    keys = raw_keys.flatten
    keys.each { |k|
      if raw_data.has_key?(k)
        require_column k
      end
    }
  end

  def optional_columns *raw_keys
    raw_params = raw_data
    keys = raw_keys.flatten
    keys.each { |k| 
      next if !raw_params.has_key?( k )
      require_column k
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


