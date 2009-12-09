
require_these 'models', [ :_couch_plastic_validator, :_couch_plastic_helper ]

module CouchPlastic
  
  include Demand_Arguments_Dsl

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
      title = self.class.to_s.gsub('CouchPlastic::Unauthorized', '')
      msg = "#{doc.inspect}, #{title}: #{mem.inspect}"
      super(msg)
    end
  end

  class UnauthorizedNew < Unauthorized; end
  class UnauthorizedReader < Unauthorized; end
  class UnauthorizedCreator < Unauthorized; end
  class UnauthorizedEditor < Unauthorized; end
  class UnauthorizedUpdator < Unauthorized; end
  class UnauthorizedDeletor < Unauthorized; end

  # =========================================================
  #           Miscellaneous Methods
  # ========================================================= 
  
  def initialize *args
    
    if args.empty?
      return super()
    end
    
    super()
    
    editor   = args.first
    raw_data.update( args[1] ) if args[1]

    if !creator?(editor)
      raise UnauthorizedNew.new(self,editor)
    end
    set_manipulator editor, raw_data

  end

  def method_missing *args
    meth_name = args.first.to_sym
    if args.size == 1 && self.class.fields.include?(meth_name)
      raise "Change API: #{args.inspect} --- LINE --- #{caller.first.inspect}" 
      return original_data.send(meth_name)
    end
    super
  end

  def new?
    original_data.as_hash.empty?
  end
 
  def human_field_name( col )
    col.to_s.gsub('_', ' ')
  end 

  # =========================================================
  #      Methods for handling Old/New Data
  # ========================================================= 

  def has?(key)
    original_data.as_hash.has_key? key
  end

  def original_data
    @original_data ||= Data_Pouch.new(*(self.class.fields))
  end
  alias_method :data, :original_data

  def new_data
    @new_data ||= begin
      dp = Data_Pouch.new(*(self.class.fields))
      
      
      dp
    end
  end

  def ask_for(*args)
    args.each { |raw_fld|
      fld = raw_fld.to_sym
      if raw_data.has_key?(fld)
        demand fld
      end
    }
  end

  def demand(*args)
    args.each { |raw_fld|
      fld = raw_fld.to_sym
      begin
        send("#{fld}_validator")
      rescue Invalid
      end
    }
  end
      
  def raw_data 
    @raw_data ||= {}
  end

  def clean_data 
    @clean_data ||={}
  end

  def assoc_cache
    @assoc_cache ||= {}
  end

  def clear_assoc_cache
    @assoc_cache = {}
  end

  # =========================================================
  #            Methods Related to DSL for Editors
  # ========================================================= 

  attr_reader :manipulator

  def set_manipulator mem, new_raw_data
    raise ArgumentError, "Method can only be used once." if @manipulator
    @manipulator = mem
    @raw_data    = new_raw_data
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
    setter_for_create
    raise_if_invalid

    data = new_data.as_hash.clone
    data[:data_model] = self.class.name
    data[:created_at] = Helper.utc_now_as_string if self.class.fields.include?(:created_at)

    new_id = data.delete(:_id) || CouchDoc.GET_uuid

    begin
      results = CouchDoc.PUT( new_id, data)
      @original_data.as_hash.update(new_data.as_hash)
      original_data._id        = new_id
      original_data._rev       = results[:rev]
      original_data.created_at = data[:created_at] if data.has_key?(:created_at)
      original_data.data_model = data[:data_model]
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
    setter_for_update
    raise_if_invalid

    data = original_data.as_hash.clone.update(new_data.as_hash)
    data[:_rev] = original_data._rev
    data[:updated_at] = Time.now.utc if self.class.fields.include?(:updated_at)
    
    begin
      results = CouchDoc.PUT( original_data._id, data )
      original_data._rev = results[:rev]
      original_data.updated_at = data[:updated_at] if data.has_key?(:updated_at)
      original_data.as_hash.update(new_data.as_hash)
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

    results = CouchDoc.delete( original_data.id, original_data._rev )
    original_data.as_hash.clear # Mark document as new.

  end

  # =========================================================
  #                  Module: ClassMethods
  # ========================================================= 
  
  module ClassMethods # =====================================

    include Demand_Arguments_Dsl

    def new_from_db(data)
      d = new
      d.original_data.as_hash.update(data)
      d
    end

    # ===== DSL-icious ======================================

    def fields 
      @fields ||= [:_id, :data_model, :_rev]
    end

    def allow_fields *args
      args.each { |fld|
        fields << fld.to_sym
      }
      @fields.uniq!
      @fields
    end

    def enable_timestamps
      allow_fields :created_at, :updated_at
    end

    # def enable *opts
    #   valid_opts = [:created_at, :updated_at]
    #   invalid_opts = opts - valid_opts
    #   if !invalid_opts.empty?
    #     raise ArgumentError, "Invalid Options: #{invalid_opts.join( ', ' )}" 
    #   end
    #   @use_options ||= []
    #   @use_options = @use_options + opts
    #   @use_options
    # end


    # ===== CRUD Methods ====================================

    def by_id( id ) # READ
      CouchDoc.GET_by_id id
    end

    def read mem, id # READ
      d = CouchDoc.GET_by_id(id)
      if !d.reader?(mem)
        raise UnauthorizedReader.new(d,mem)
      end
      d
    end

    def edit mem, id # EDIT
      d = CouchDoc.GET_by_id(id)
      if !d.updator?(mem)
        raise UnauthorizedEditor.new(d,mem)
      end
      d
    end

    def create editor, new_raw_data # CREATE
      d = new
      if !d.creator?(editor)
        raise UnauthorizedCreator.new(d,editor)
      end
      d.set_manipulator editor, new_raw_data
      d.save_create 
      d
    end

    def update editor, new_raw_data # UPDATE
      d = CouchDoc.GET_by_id(new_raw_data[:id])
      if !d.updator?(editor)
        raise UnauthorizedUpdator.new(d,editor)
      end
      d.set_manipulator editor, new_raw_data
      d.save_update 
      d
    end

    def delete! editor, new_raw_data # DELETE
      d = CouchDoc.GET_by_id(new_raw_data[:id])
      if !d.deletor?(editor)
        raise UnauthorizedDeletor.new(d, editor)
      end
      d.delete!
      d
    end


  end # === module ClassMethods ==============================================


end # === module CouchPlastic ================================================




__END__


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
 

