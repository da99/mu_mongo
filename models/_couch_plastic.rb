

module CouchPlastic
  
  # =========================================================
  #                  self.included
  # ========================================================= 

  def self.included(target)
    target.extend ClassMethods
  end

  # =========================================================
  #                  Error Constants
  # ========================================================= 

  class NoRecordFound < StandardError; end
  class NoNewValues < StandardError; end
  class HTTPError < StandardError; end
  
  class Invalid < StandardError
    attr_accessor :doc
    def initialize doc, msg=nil
      @doc = doc
      super(msg + ": #{doc.errors.join(' * ')}")
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
  #           Miscellaneous Methods
  # ========================================================= 
  
  def method_missing *args
    meth_name = args.first.to_sym
    if args.size == 1 && original.has_key?(meth_name)
      return original[meth_name]
    end
    super
  end

  def new?
    original.empty?
  end
 
  def human_field_name( col )
    col.to_s.gsub('_', ' ')
  end 

  # =========================================================
  #      Methods for handling Old/New Data
  # ========================================================= 

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
 
  def assoc_cache
    @assoc_cache ||= {}
  end

  def clear_assoc_cache
    @assoc_cache = {}
  end

  # =========================================================
  #                     DSL-icious
  # ========================================================= 

  attr_accessor :current_editor, :raw_data

  def apply_new_data action, editor, raw_data

    if action != :create && new?
      raise ArgumentError, "Invalid action for new record: #{action.inspect}" 
    end

    if action == :create && !new?
      raise ArgumentError, "Invalid action for existing record: #{action.inspect}" 
    end

    blok = self.class.actions[action]
    self.current_editor = editor
    self.raw_data = raw_data
    instance_eval &blok

  end

  def demand *cols
    cols.flatten.each { |k|
      send("#{k}=", raw_data)
    }
  end
  
  def ask_for *cols
    cols.flatten.each { |k|
      if raw_data.has_key?(k)
        send("#{k}=", raw_data)
      end
    }
  end

  def from raw_member_level, &blok
    member_level = case raw_member_level
      when :self
        self
      else
        raw_member_level
    end

    if !current_editor && member_level == Member::STRANGER
      instance_eval &blok 
    elsif current_editor && current_editor.has_power_of?(member_level)
      instance_eval &blok
    else 
    end
  end

  # =========================================================
  #               Save & Delete Methods
  # ========================================================= 

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
    data[:created_at] = Time.now.utc if self.class.enabled?(:created_at)

    new_id = data.delete(:_id) || CouchDoc.GET_uuid

    begin
      results = CouchDoc.PUT( new_id, data)
      _set_original_(original.update(new_values))
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

  # Accepts an optional block that is given, if any, a RestClient::RequestFailed
  # exception.  Use ".response.body" on the exception for JSON data.
  # Parameters:
  #   opts - Valid options: :set_updated_at
  def save_update *opts

    clear_assoc_cache
    validate

    data = new_values.clone
    data[:_rev] = original[:_rev]
    data[:updated_at] = Time.now.utc if self.class.enabled?(:updated_at)
    
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

  def delete!
    
    clear_assoc_cache

    results = CouchDoc.delete( original[:id], original[:_rev] )
    original.clear # Mark document as new.

  end

  # =========================================================
  #               Validation-related Methods
  # ========================================================= 

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
 

  # =========================================================
  #                  Module: ClassMethods
  # ========================================================= 
  
  module ClassMethods # =====================================

    def new_from_db(data)
      d = new
      d._set_original_(data)
      d
    end

    # ===== DSL-icious ======================================

    def actions
      @crud_tailors ||= {:create=>nil,:update=>nil, :read=>nil, :delete=>nil}
    end

    def during action, &blok
      if actions[action]
        raise ArgumentError, "Already used: #{action.inspect}" 
      end
      actions[action] = blok
    end

    def enable_timestamps
      enable :created_at, :updated_at
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

    def enabled? opt
      @use_options ||=[]
      @use_options.include? opt.to_sym
    end

    # ===== CRUD Methods ====================================

    def by_id( id ) # READ
      CouchDoc.GET_by_id id
    end

    def show mem, id # READ
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

    def create editor, raw_data # CREATE
      d = new(editor)
      d.apply_new_data :create, editor, raw_data
      raise UnauthorizedCreator.new( self, editor ) if !d.creator?( editor )
      d.save_create 
      d
    end

    def update editor, raw_data # UPDATE
      d = CouchDoc.GET_by_id(raw_data[:id])
      d.apply_new_data :update, editor, raw_data
      raise UnauthorizedUpdator.new( self, editor ) if !d.updator?(editor)
      d.save_update 
      d
    end

    def delete! editor, raw_data # DELETE
      d = CouchDoc.GET_by_id(raw_data[:id])
      raise UnauthorizedDeletor.new( self, editor ) if !deletor?(editor)
      d.delete!
      d
    end


  end # === module ClassMethods ==============================================


end # === model: Sequel::Model -------------------------------------------------


