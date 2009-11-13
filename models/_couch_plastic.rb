

module CouchPlastic
  

  # =========================================================
  #                     Error Constants
  # ========================================================= 

  class NoRecordFound < StandardError; end
  class NoNewValues < StandardError; end
  class HTTPError < StandardError; end
  
  class Invalid < StandardError
    attr_accessor :doc
    def initialize doc, msg=nil
      @doc = doc
      super(msg)
    end
  end

  class Unauthorized < StandardError
    def initialize doc, mem=nil
      if doc.is_a?(String)
        return super(doc)
      end
      title = self.class.to_s.gsub('Unauthorized', '')
      msg = "#{doc.inspect}, #{title}: #{mem.inspect}"
      super(msg)
    end
  end

  class UnauthorizedNew < Unauthorized; end
  class UnauthorizedViewer < Unauthorized; end
  class UnauthorizedCreator < Unauthorized; end
  class UnauthorizedEditor < Unauthorized; end
  class UnauthorizedUpdator < Unauthorized; end
  class UnauthorizedDeletor < Unauthorized; end

  # =========================================================
  #                  Module: ClassMethods
  # ========================================================= 
  
  module ClassMethods # =====================================

    # ===== DSL-icious ======================================

    def required_for_create *cols 
      raise "Method can only be used once." if constants.include?('REQUIRED_FOR_CREATE')
      const_set('REQUIRED_FOR_CREATE', cols)
    end

    def optional_for_create *cols 
      raise "Method can only be used once." if constants.include?('OPTIONAL_FOR_CREATE')
      const_set('OPTIONAL_FOR_CREATE', cols)
    end

    def required_for_update *cols
      raise "Method can only be used once." if constants.include?('REQUIRED_FOR_UPDATE')
      const_set('REQUIRED_FOR_UPDATE', cols)
    end

    def optional_for_update *cols
      raise "Method can only be used once." if constants.include?('OPTIONAL_FOR_UPDATE')
      const_set('OPTIONAL_FOR_UPDATE', cols)
    end

    def enable *opts
      valid_opts = [:created_at, :updated_at]
      invalid_opts = opts - valid_opts
      if !invalid_opts.empty?
        raise ArgumentError, "Invalid Options: #{invalid_opts.join( ', ' )}" 
      end
      @use_options ||= []
      @use_options = @use_options + opts
      @use_options
    end



    # ===== CRUD Methods ====================================

    def show mem, id
      d = CouchDoc.GET_by_id(id)
      if !d.viewer?(mem)
        raise UnauthorizedViewer.new( self, mem )
      end
      d
    end

    def edit mem, id
      d = CouchDoc.GET_by_id(id)
      if !d.updator?(mem)
        raise UnauthorizedEditor.new( self, mem )
      end
      d
    end

    def create editor, raw_data
      d = new(editor)
      d.set_required raw_data
      d.set_optional raw_data
      d.save_with_creator editor
      d
    end

    def update editor, raw_data
      d = CouchDoc.GET_by_id(raw_data[:id])
      d.set_required raw_data
      d.set_optional raw_data
      d.save_with_updator editor
      d
    end

    def delete! editor, raw_data
      d = CouchDoc.GET_by_id(raw_data[:id])
      d.delete_with_deletor! editor
      d
    end


  end # === module ClassMethods ==============================================

 
  def self.included(target)
    target.extend ClassMethods
  end


  attr_accessor :current_editor, :raw_data
  
  def method_missing *args
    meth_name = args.first.to_sym
    if args.size == 1 && original.has_key?(meth_name)
      return original[meth_name]
    end
    super
  end

  def initialize(*opts)
    if !opts.empty?
      mem = opts.shift
      if !opts.empty?
        raise ArgumentError, "Unknown options: #{opts.inspect}"
      end
      if !self.creator?(mem)
        raise UnauthorizedNew.new(self, opts)
      end
    end
    super()
  end
 
  def set_required raw_data
    REQUIRED_FOR_CREATE.each { |c|
      d.send("#{c}=", raw_data)
    }
  end

  def set_optional raw_data
    OPTIONAL_FOR_UPDATE.each { |c|
      if raw_data.has_key?(c)
        d.send("#{c}=", raw_data)
      end
    }
  end


  def human_field_name( col )
    col.to_s.gsub('_', ' ')
  end 
  
  def assoc_cache
    @assoc_cache ||= {}
  end

  def clear_assoc_cache
    @assoc_cache = {}
  end


  def original
    @original ||= {}
  end

  def _set_original_(new_hash)
    raise ArgumentError, "Only a Hash is allowed." if !new_hash.is_a?(Hash)
    @original = new_hash
  end

  def new_values
    @new_values ||= {}
  end

  def new?
    original.empty?
  end
  
  def save_with_creator mem, *opts, &blok
    if !creator?(editor)
      raise UnauthorizedCreator.new( self, mem )
    end
    save_create *opts, &blok
  end

  # Accepts an optional block that is given, if any, a RestClient::RequestFailed
  # exception.  Use ".response.body" on the exception for JSON data.
  # Parameters:
  #   opts - Valid options: :set_created_at
  def save_create *opts

    raise "This is not a new document." if !new?

    clear_assoc_cache
    validate

    data = new_values.clone
    data[:data_model] = self.class.name
    data[:created_at] = Time.now.utc if opts.include?(:set_created_at)

    new_id = data.delete(:_id) || CouchDoc.GET_uuid

    begin
      results = CouchDoc.PUT( new_id, data)
      _set_original(original.update(new_values))
      original[:_id]        = new_id
      original[:_rev]       = results[:rev]
      original[:created_at] = data[:created_at] if data.has_key?(:created_at)
      original[:data_model] = data[:data_model]
    rescue RestClient::RequestFailed
      if block_given?
        yield $!
      else
        raise
      end
    end

  end

  def save_with_updator mem, *opts, &blok
    if !updator?(mem)
      raise UnauthorizedUpdator.new( self, mem )
    end
    save_update *opts, &blok
  end


  # Accepts an optional block that is given, if any, a RestClient::RequestFailed
  # exception.  Use ".response.body" on the exception for JSON data.
  # Parameters:
  #   opts - Valid options: :set_updated_at
  def save_update *opts

    clear_assoc_cache
    validate

    data = new_values.clone
    data[:_rev] = original[:_rev]
    data[:updated_at] = Time.now.utc if opts.include?(:set_updated_at)
    
    begin
      results = CouchDoc.PUT( original[:_id], data.to_json )
      original[:_rev] = results[:rev]
      original[:updated_at] = data[:updated_at] if data.has_key?(:updated_at)
      _set_original_(original.update(new_values))
    rescue RestClient::RequestFailed
      if block_given?
        yield $!
      else
        raise
      end
    end
  end

  def delete_with_deletor! mem
    if !deletor?(mem)
      raise UnauthorizedDeletor.new( self, mem )
    end
  end

  def delete!
    
    clear_assoc_cache

    results = CouchDoc.delete( original[:id], original[:_rev] )
    original.clear # Mark document as new.

  end
  

  # =========================================================
  #               Authorization Methods
  # ========================================================= 

  # def self.get_for_creator mem # CREATE
  #   if creator?
  #     raise UnauthorizedCreator, "#{mem.inspect}" 
  #   end
  #   new
  # end

  # def self.get_for_viewer mem, id # SHOW
  #   d = CouchDB.GET_by_id(id)
  #   if d.viewer? mem
  #     raise UnauthorizedViewer, "Doc: #{id.inspect}, Viewer: #{mem.inspect}"
  #   end
  #   d
  # end

  # def self.get_for_editor mem, id # EDIT
  #   d = CouchDB.GET_by_id(id)
  #   if d.editor?(mem)
  #     raise UnauthorizedEditor, "Doc: #{id.inspect}, Editor: #{mem.inspect}"
  #   end
  #   d
  # end

  # def self.get_for_updator mem, id # UPDATE
  #   d = CouchDB.GET_by_id id
  #   if d.updator?(mem)
  #     raise UnauthorizedUpdator, "Doc: #{id.inspect}, Updator: #{mem.inspect}"
  #   end
  #   d
  # end

  # def self.get_for_deletor mem, id # DELETE
  #   d = CouchDB.GET_by_id id
  #   if d.deletor? mem
  #     raise UnauthorizedDeletor, "Doc: #{id.inspect}, Deletor: #{mem.inspect}"
  #   end
  #   d
  # end
  


  # =========================================================
  #               Validation-related Methods
  # ========================================================= 

  def set_optional_values raw_vals, *cols
    cols.flatten.each { |k|
      if raw_vals.has_key?(k)
        send("#{k}=", raw_vals[k])
      end
    }
  end

  def errors
    @errors ||= []
  end

  def validate
    if !errors.empty? 
      raise Invalid.new( self, "Document has validation errors." )
    end

    if new_values.empty?
      raise NoNewValues, "No new data to save."
    end

    true
  end 


  def validate_editor editor, *levels
    l = levels.detect { |lev| 
      editor.has_power_of?(lev) 
    }

    l || raise( UnauthorizedEditor, "#{editor.inspect} not allowed: #{levels.inspect}" )
  end  
  
  
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


__END__

    # =========================================================
    # From: http://snippets.dzone.com/posts/show/2992
    # Note: Don't cache subclasses because new classes may be
    # defined after the first call to this method is executed.
    # =========================================================
    def all_subclasses
      all_subclasses = []
      ObjectSpace.each_object(Class) { |c|
                next unless c.ancestors.include?(self) and (c != self)
                all_subclasses << c
      }
      all_subclasses 
    end # ---- self.all_subclasses --------------------


    def editor_permissions
      @editor_perms
    end 

    def allow_viewer *levels 
      add_perm_for_editor :show, levels
    end
    
    def allow_creator( *levels, &blok ) 
      add_perm_for_editor(:create, levels, &blok)
    end

    def allow_updator( *levels, &blok )
      add_perm_for_editor(:update, levels, &blok)
    end 

    def add_perm_for_editor( action, levels, &blok)
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


    def validator col, &blok
      define_method "validator_for_#{col}", &blok
    end

    def creator editor, raw_vals
      n = new
      level = creator? editor
      raise UnauthorizedEditor, editor.inspect if !level
      n.current_editor = editor
      n.raw_data = raw_vals
      n.instance_eval &(editor_permissions[:create][level])
      n.raise_if_invalid
      n.created_at = Time.now.utc if n.respond_to?(:created_at)
      n.save
    end

    def creator? editor
      
      levels = editor_permissions[:create].keys
      levels.detect { |lev|
        if !editor || editor == :STRANGER
          lev == :STRANGER
        else
          editor.has_power_of?(lev)
        end
      }

    end

    def updator editor, raw_vals
      rec = self[:id=>raw_vals[:id]]
      raise NoRecordFound, "Try again." if !rec
      level = rec.updator?( editor )
      raise UnauthorizedEditor, editor.inspect if !level
      rec.current_editor = editor
      rec.raw_data       = raw_vals
      rec.instance_eval &(editor_permissions[:update][level])
      rec.raise_if_invalid
      rec.updated_at = Time.now.utc if rec.respond_to?(:updated_at)
      rec.save
    end



  def raise_if_invalid
    raise Sequel::ValidationFailed, errors.full_messages if !errors.full_messages.empty?
  end 
 
  def raw_data 
    @raw_data ||= {}
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

  def save
     
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













