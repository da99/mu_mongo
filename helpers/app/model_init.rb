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
  
  def self.editor_permissions
    @editor_perms
  end 

  def self.allow_viewer *levels 
    add_perm_for_editor :show, levels
  end
  
  def self.allow_creator( *levels, &blok ) 
    add_perm_for_editor(:create, levels, &blok)
  end

  def self.allow_updator( *levels, &blok )
    add_perm_for_editor(:update, levels, &blok)
  end 

  def self.add_perm_for_editor( action, levels, &blok)
    raise ArgumentError, "Block required for #{action.inspect}" if !block_given? && action != :show
    raise ArgumentError, "Invalid action type: #{action.inspect}" if ![:create, :update, :show].include?(action)
    raise ArgumentError, "nil not allowed among other levels" if levels.length > 1 && levels.include?(nil)
    @editor_perms ||= {:create=>{}, :update=>{}, :show=>{}}  
    levels.each do |raw_lev|
      stranger_level = ( raw_lev.nil? || raw_lev == 0 )
      lev = ( stranger_level ? :STRANGER : raw_lev )
      raise "#{lev.inspect} already used for #{action.inspect}." if @editor_perms[action].has_key?(lev)
      @editor_perms[action][lev] = blok
    end
  end

  def self.validator col, &blok
    define_method "validator_for_#{col}", &blok
  end

  def self.creator editor, raw_vals
    n = new
    level = creator? editor
    raise UnauthorizedEditor, editor.inspect if !level
    n.current_editor = editor
    n.raw_data = raw_vals
    n.instance_eval &(editor_permissions[:create][level])
    n.raise_if_invalid
    n.created_at = Time.now.utc if n.respond_to?(:created_at)
    n._save_
  end

  def self.creator? editor
    
    levels = editor_permissions[:create].keys
    levels.detect { |lev|
      if !editor || editor == :STRANGER
        lev == :STRANGER
      else
        editor.has_power_of?(lev)
      end
    }

  end

  
  def self.updator editor, raw_vals
    rec = self[:id=>raw_vals[:id]]
    raise NoRecordFound, "Try again." if !rec
    level = rec.updator?( editor )
    raise UnauthorizedEditor, editor.inspect if !level
    rec.current_editor = editor
    rec.raw_data       = raw_vals
    rec.instance_eval &(editor_permissions[:update][level])
    rec.raise_if_invalid
    rec.updated_at = Time.now.utc if rec.respond_to?(:updated_at)
    rec._save_
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
   
  attr_accessor :current_editor, :raw_data
 
  def raise_if_invalid
    raise Sequel::ValidationFailed, errors.full_messages if !errors.full_messages.empty?
  end 
 
  def raw_data 
    @raw_data ||= {}
  end

  def human_field_name( col )
    col.to_s.gsub('_', ' ')
  end

  def viewer? editor
    levels = self.class.editor_permissions[:show].keys
    return true if levels.include?(:STRANGER)
    updator?(editor) || self.class.creator?(editor)
  end

  def updator? editor
    levels = self.class.editor_permissions[:update].keys
    levels.detect { |lev|
      if !editor
        lev == :STRANGER
      else
        if Member::SECURITY_LEVEL_NAMES.include?(lev)
          editor.has_power_of?(lev) && lev
        else respond_to?(lev) 
          editor_list = ( lev == :self ? self : send(lev) )
          editor_list = [editor_list].flatten
          editor_list.detect { |ed| 
            ed.has_power_of?(editor)
          }
        end
      end
    }

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

  def has_tag_id?(tag_id)
    @tag_ids ||= taggings_dataset.naked.map(:tag_id)
    @tag_ids.include?(tag_id.to_i)
  end

  def require_columns *raw_keys
    keys = raw_keys.flatten
    keys.each { |k| 
        send( "validator_for_#{k}"  )
    }
  end # === def
  
  def optional_columns *raw_keys
    keys = raw_keys.flatten
    keys.each { |k| 
      if raw_data.has_key?( k )
        require_columns k
      end
    }
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
    clean = raw_data[field_name].to_s.strip
    
    if clean.empty?
      error_msg  = ( raw_error_msg || "is required." ).strip
      self.errors.add( field_name, error_msg )
      return nil
    else
      self[field_name] = clean
    end
  end

  def optional_string field_name
    clean = raw_data[field_name].to_s.strip
    if clean.empty?
      self[field_name] = nil
    else
      self[field_name] = clean
    end
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

  def require_same_owner assoc_name
    
    return if self[:owner_id].to_i < 1
    assoc_reflect = self.association_reflections[assoc_name]
    m_class = Object.const_get( assoc_reflect[:class_name] )
    m_id_int = raw_data[m_id].to_i
    return if m_id_int < 1

    m_obj = m_class[:id=>m_id_int ]

    if !m_obj
      self[assoc_reflect[:key]] = nil
    else
      if m_obj[:owner_id] != self[:owner_id]
        raise %~
        Potential security threat: #{self.class} owner, #{self[:owner_id]} 
        not owner of #{m_class} #{m_obj[:owner_id]}
        ~.strip.gsub("\n", ' ')
      end
      self[assoc_reflect[:key]] = m_id_int
    end
   
  end
 
 
end # === model: Sequel::Model -------------------------------------------------


require_these '../models'


