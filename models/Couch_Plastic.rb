
module Couch_Plastic
  
  include Demand_Arguments_Dsl

	Time_Format = '%Y-%m-%d %H:%M:%S'.freeze
	
  # =========================================================
  #                  self.included
  # ========================================================= 

  def self.included(target)
    target.extend Couch_Plastic_Class_Methods
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
      title = self.class.to_s.gsub('Couch_Plastic::Unauthorized', '')
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
    
    self.set_manipulator args.first
    self.set_raw_data( args[1] ) if args[1]

    if !creator?(editor)
      raise UnauthorizedNew.new(self,editor)
    end
    set_manipulator editor

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

  def set_original_data new_hash
		@original_data = nil
    new_hash.each { |k,v|
      original_data.send "#{k}=", self.class.format_field(k, v)
    }
    original_data
  end
  
  def new_data
    @new_data ||= begin
      dp = Data_Pouch.new(*(self.class.fields))
      dp
    end
  end

  def value_is_clean field_name
    raise "implement"
  end

  def set_cleanest_value field_name, val
    clean_data[field_name] = val
		begin
			new_data.send "#{field_name}=", val
		rescue NoMethodError
		end
		val
  end

  def cleanest_value field_name
    if new_data.as_hash.has_key?(field_name) 
      new_data.send( field_name )
    elsif clean_data.has_key?(field_name)
      clean_data[field_name]
    else
      raw_data[field_name]
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

  def demand(*args, &blok)
    if block_given?
      raise "not implemented"
    else
      args.each { |raw_fld|
        fld = raw_fld.to_sym
        begin
          send("#{fld}_validator")
        rescue Invalid
        end
      }
    end
  end
      
  def raw_data 
    @raw_data ||= {}
  end

  def set_raw_data  new_hash
    @raw_data = new_hash
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
  #            Methods Related to Timestamps
  # ========================================================= 

  def last_modified_at
    return nil unless self.class.timestamps_enabled?
    updated_at || created_at
  end

  def created_at
    return nil unless self.class.allow_fields.include?(:created_at)
    original_data.created_at.to_time
  end

  def updated_at
    return nil unless self.class.allow_fields.include?(:updated_at)
		return nil if original_data.updated_at.nil?
    original_data.updated_at.to_time
  end
  
  
  # =========================================================
  #            Methods Related to DSL for Editors
  # ========================================================= 

  attr_reader :manipulator

  def set_manipulator mem
		if instance_variable_defined? :@manipulator
			raise ArgumentError, "Method can only be used once." 
		end
    @manipulator = mem
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
    before_create
    raise_if_invalid

    data = new_data.as_hash.clone
    data[:data_model] = self.class.name
    data[:created_at] = Time.now.utc.strftime(Time_Format) if self.class.fields.include?(:created_at)

    new_id = data.delete(:_id) || Couch_Doc.GET_uuid

    begin
      results = Couch_Doc.PUT( new_id, data)
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
    before_update
    raise_if_invalid

    data = original_data.as_hash.clone.update(new_data.as_hash)
    data[:_rev] = original_data._rev
    data[:updated_at] = Time.now.utc if self.class.fields.include?(:updated_at)
    
    begin
      results = Couch_Doc.PUT( original_data._id, data )
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

    results = Couch_Doc.delete( original_data.id, original_data._rev )
    original_data.as_hash.clear # Mark document as new.

  end

  # =========================================================
  #                  Validator Helpers
  # ========================================================= 

  def errors
    @errors ||= []
  end

  def raise_if_invalid
    
    if !errors.empty? 
      raise Invalid.new( self, "Document has validation errors." )
    end

    if new_data.as_hash.empty?
      raise NoNewValues, "No new data to save."
    end

    true

  end 
  
  def validator_field_name
     line = caller[0,3].detect { |meth| meth['_validator']} 
		 raise "Name of validator not found." unless line
		 line =~ /`([^']*)_validator'/ && $1.to_sym
  end

  def accept_anything
    field = validator_field_name
    set_cleanest_value(
      field,
      raw_data[field]
    )
  end

  def sanitize &blok
    field = validator_field_name
    val   = cleanest_value( field ) 
    val.extend Couch_Plastic_Sanitizer_Methods
    set_cleanest_value(
      field, 
      raw_data[field].instance_eval(&blok)
    )
  end

  def must_be &blok
    begin
      new_validator = Couch_Plastic_Validator.new(self, validator_field_name )
      new_validator.instance_eval( &blok )
    rescue Couch_Plastic_Validator::Invalid
    end
  end

  def must_be_or_raise! &blok
    begin
      new_vald = Couch_Plastic_Validator.new(self, validator_field_name)
      new_vald.use_runtime_error
      new_vald.instance_eval( &blok )
    rescue Couch_Plastic_Validator::Invalid
    end
  end

end # === module Couch_Plastic ================================================


module Couch_Plastic_Sanitizer_Methods

  def with regexp, &blok
		if is_a?(String)
			gsub regexp, &blok
		end
  end

end # === 

class Couch_Plastic_Validator

  Invalid = Class.new(StandardError)

  attr_reader :doc, :field_name, :english_field_name

  def initialize new_doc, new_field_name, &blok
    @doc                = new_doc
    @field_name         = new_field_name.to_sym
    @english_field_name = @field_name.to_s.capitalize.gsub('_', ' ')
  end

  def use_runtime_error 
    @raise_on_error = true
  end

  def use_runtime_error?
    !!@raise_on_error
  end

  def record_error new_msg
    msg = (new_msg % english_field_name)
    raise msg if use_runtime_error?
    doc.errors << msg
    raise Invalid, "Error found on #{field_name}"
  end

  def clean_val
    doc.cleanest_value field_name
  end


  # ======== Methods for validation.

  # def error_msg new_msg = nil
  #   return @error_msg unless new_msg
  #   @error_msg = new_msg
  # end

  def not_empty
    if clean_val.nil? || clean_val.strip.empty?
      record_error '%s is required.'
    end
  end

  def equal val, err_msg = nil
    if clean_val != val
      record_error( err_msg || "%s must be equal to #{val.inspect}" )
    end
  end

  def in_array arr, err_msg = nil
    unless arr.include?(clean_val)
      default_err = "%s is invalid. Must be either: #{arr.map(&:inspect).join(', ')}"
      record_error( err_msg || default_err )
    end
  end

  def match regexp, err_msg = nil
    if clean_val !~ regexp
      record_error( err_msg || '%s is invalid.')
    end
  end

	def not_match regexp, err_msg = nil
		if clean_val =~ regexp
			record_error( err_msg || '%s has invalid characters.' )
		end
	end

	def between_size raw_start, raw_end, err_msg = nil
		min_size raw_start, err_msg
		max_size raw_end, err_msg
	end

  def max_size raw_int, err_msg = nil
    if !clean_val.respond_to?(:jsize) ||
       clean_val.jsize >= raw_int.to_i
      
      record_error( err_msg || "%s is too large. #{raw_int} characters is the maximum allowed." )
      
    end
  end

  def min_size raw_int, err_msg = nil
    if !clean_val.respond_to?(:jsize) ||
       clean_val.jsize <= raw_int.to_i
      
      record_error( err_msg || "%s must be at least #{raw_int} characters long." )
      
    end
  end

  def not_in_array arr, err_msg = nil
    if arr.include?(clean_val)
      record_error( err_msg || '%s is already taken.' )
    end
  end

  def string err_msg = nil
    if not clean_val.is_a?(String)
      record_error( err_msg || '%s is invalid.' )
    end
  end

end # === Couch_Plastic_Validator



# =========================================================
# === Module: Class Methods for Couch_Plastic 
# ========================================================= 

module Couch_Plastic_Class_Methods 

  include Demand_Arguments_Dsl

  # ===== DSL-icious ======

  def fields 
    @fields ||= [:_id, :data_model, :_rev]
  end

  def formatters
    @formatters ||= {}
  end

  def format_field k, v
    raise "Unknown field: #{k.inspect}" unless allow_fields.include?(k)
    return v unless formatters.has_key?(k)

    case formatters[k]
      when Symbol
        v.to_sym
      when Proc
        formatters[k].call v
    end
  end

  def allow_fields *args
    args.each { |fld|
      case fld
        when Array

          case fld.last
            when Symbol, Proc
            else
              raise "Unknown formatter class: #{fld.last.inspect}"
          end
          
          fld_sym = fld.first.to_sym
          fields << fld_sym
          formatters[fld_sym] = fld.last
          
        else
          fields << fld.to_sym
      end
    }
    @fields.uniq!
    @fields
  end

  def enable_timestamps
    allow_fields :created_at, :updated_at
  end

  def timestamps_enabled?
    allow_fields.include?(:created_at) &&
      allow_fields.include?(:updated_at)
  end


  # ===== CRUD Methods ====================================

  def by_id( id ) # READ
    Couch_Doc.GET_by_id id
  end

  def read mem, id # READ
    d = Couch_Doc.GET_by_id(id)
    if !d.reader?(mem)
      raise UnauthorizedReader.new(d,mem)
    end
    d
  end

  def edit mem, id # EDIT
    d = Couch_Doc.GET_by_id(id)
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
    d.set_manipulator editor
    d.set_raw_data  new_raw_data
    d.save_create 
    d
  end

  def update editor, new_raw_data # UPDATE
    d = Couch_Doc.GET_by_id(new_raw_data[:id])
    if !d.updator?(editor)
      raise UnauthorizedUpdator.new(d,editor)
    end
    d.set_manipulator editor
    d.set_raw_data new_raw_data
    d.save_update 
    d
  end

  def delete! editor, new_raw_data # DELETE
    d = Couch_Doc.GET_by_id(new_raw_data[:id])
    if !d.deletor?(editor)
      raise UnauthorizedDeletor.new(d, editor)
    end
    d.delete!
    d
  end


end # === module ClassMethods ==============================================


