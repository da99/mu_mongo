

module Couch_Plastic
  
	Time_Format = '%Y-%m-%d %H:%M:%S'.freeze
  LANGS = eval(File.read(File.expand_path("./helpers/langs_hash.rb")))
	
  # =========================================================
  #                  self.included
  # ========================================================= 

  def self.included(target)
    target.extend Couch_Plastic_Class_Methods
  end

	def self.utc_now
		Time.now.utc.strftime(Time_Format)
	end

  def self.utc_date_now
    Time.now.utc.strftime(Time_Format.split(' ').first)
  end
  
  def self.utc_time_now
    Time.now.utc.strftime(Time_Format.split(' ').last)
  end
  
	def self.utc_string time_or_str
		time = case time_or_str
      when Time 
        time_or_str
      when String
        require 'time'
        Time.parse(time_str)
    end
    time.strftime(Time_Format)
	end

  # =========================================================
  #                  Error Constants
  # ========================================================= 

  Nothing_To_Update       = Class.new(StandardError)
  Raw_Data_Field_Required = Class.new(StandardError)
  
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
      title = self.class.to_s.gsub('Couch_Plastic::Unauthorized_', '')
      msg = "#{doc.inspect}, #{title}: #{mem.inspect}"
      super(msg)
    end
  end

  class Unauthorized_New < Unauthorized; end
  class Unauthorized_Reader < Unauthorized; end
  class Unauthorized_Creator < Unauthorized; end
  class Unauthorized_Editor < Unauthorized; end
  class Unauthorized_Updator < Unauthorized; end
  class Unauthorized_Deletor < Unauthorized; end

  # =========================================================
  #           Miscellaneous Methods
  # ========================================================= 
  
	attr_reader :data, :new_data, :raw_data, :clean_data, :assoc_cache

  def inspect
    "#<#{self.class}:#{self.object_id} id=#{self.data._id}>"
  end

  def == val
    return false unless val.respond_to?(:data)
    return true if equal?(val)
    return false if new? || val.new?
    data.as_hash == val.data.as_hash
  end

  def new?
    !data?
  end

  def new_data?
    !( new_data.as_hash.empty? || 
       new_data.as_hash == data.as_hash 
     )
  end

  def data?
    @orig_doc && !@orig_doc.empty?
  end

  def raw_data?
    raw_data && !raw_data.empty?
  end
 
  def human_field_name( col )
    col.to_s.gsub('_', ' ')
  end 
  
  def clear_assoc_cache
    @assoc_cache = {}
  end

  # 
  # Parameters:
  #   doc_id_or_hash - Optional. If String, used as a doc ID to
  #                    search. If Hash, used as original data.
  #   manipulator    - Optional
  #   raw_data       - Optional
  #
  def initialize *args
    
    super()
    
		@manipulator = nil
		@clean_data  = {}
    @assoc_cache = {}
		doc_id_or_hash = args.shift
		@manipulator = args.shift
		@raw_data    = (args.shift || {})
    @orig_doc    = case doc_id_or_hash
                     when String
                       CouchDB_CONN.GET(doc_id_or_hash)
                     when Hash
                       doc_id_or_hash
                     when nil
                     else
                       raise ArgumentError, "Unknown type for first argument: #{doc_id_or_hash.inspect}"
                   end
      
    @data = Class.new {
      def initialize( doc )
        @doc    = doc
        @fields = doc.class.fields
      end

      def include?(key)
        as_hash.has_key?(key)
      end
    
      def as_hash
        (@doc.instance_variable_get :@orig_doc ) || {}
      end

      def respond_to? raw_meth
        meth = raw_meth.to_sym
        @fields.include?(meth) || super(meth)
      end
    
      def method_missing( raw_key, *args )
        key = raw_key.to_sym
        return(as_hash[key]) if @fields.include?(key)
        raise NoMethodError, "#{raw_key.inspect} is not defined, nor is it a key."
      end
    }.new(self)
      
			
		@new_data = Class.new {
				
				def initialize( doc )
          @doc    = doc
          @keys   = doc.class.fields
          @hash   = (doc.instance_variable_get :@orig_doc ) || {}
					@equals = @keys.inject({}) { |m, k| m["#{k}=".to_sym] = k; m }
				end

        def include?(key)
          @hash.has_key?(key)
        end

				def as_hash
          @hash
				end

        def respond_to? raw_meth
          meth = raw_meth.to_sym
          @keys.include?(meth) || super(meth)
        end
			
				def method_missing( raw_key, *args )
					key = raw_key.to_sym
          
					return as_hash[key] if @keys.include?(key)
          
					if @equals.has_key?(key)
						return( as_hash[@equals[key]] = args.first )
					end
          
          raise NoMethodError, "#{raw_key.inspect} is not defined, nor is it a key."
				end
				
		}.new(self)

  end

  # =========================================================
  #      Methods for handling Old/New Data
  # ========================================================= 

  def new_clean_value field_name, val
    
    clean_data[field_name] = val
    
    if self.class.fields.include?(field_name)
      new_data.send "#{field_name}=", val
    elsif self.class.proto_fields.include?(field_name)
      # ignore
    else
      raise "Unknown field being set: #{field_name.inspect} (value: #{val.inspect})"
    end
    
		val
    
  end

  def cleanest field_name
    
    self.class.assert_field(field_name)
    
    if new_data.include?(field_name) 
      new_data.send( field_name )
    elsif clean_data.has_key?(field_name)
      clean_data[field_name]
    elsif raw_data.has_key?(field_name)
      raw_data[field_name]
    else
      if self.class.fields.include?(field_name)
        data.send( field_name )
      else
        nil
      end
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
      args.each { |fld|
				
				if not raw_data.has_key?(fld)
					raise Raw_Data_Field_Required, fld.inspect
				end
				
        begin
          send("#{fld}_validator")
        rescue Invalid
        end
				
      }
    end
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
    data.created_at.to_time
  end

  def updated_at
    return nil unless self.class.allow_fields.include?(:updated_at)
		return nil if data.updated_at.nil?
    data.updated_at.to_time
  end
  
  
  # =========================================================
  #            Methods Related to DSL for Editors
  # ========================================================= 

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

    new_data.data_model = self.class.name
    new_data.created_at = Couch_Plastic.utc_now if self.class.fields.include?(:created_at)
    new_id              = begin
                            new_data.as_hash.delete(:_id) || CouchDB_CONN.GET_uuid
                          end
    vals                = new_data.as_hash.clone

    err = begin
      results          = CouchDB_CONN.PUT( new_id, vals )
      @orig_doc        = vals
      @orig_doc[:_id]  = new_id
      @orig_doc[:_rev] = results[:rev]
      nil
    rescue Object
      $!
    end

    return :ok unless err
    
    if block_given?
      yield err
    else
      on_error_save_create err
    end
  end

  def on_error_save_create err
    raise err
  end

  # Accepts an optional block that is given, if any, a RestClient::RequestFailed
  # exception.  Use ".response.body" on the exception for JSON data.
  # Parameters:
  #   opts - Valid options: :set_updated_at
  def save_update *opts

    clear_assoc_cache
    before_update
    raise_if_invalid

    data = data.as_hash.clone.update(new_data.as_hash)
    data[:_rev] = data._rev
    data[:updated_at] = Time.now.utc if self.class.fields.include?(:updated_at)
    
    begin
      results = Couch_Doc.PUT( data._id, data )
      data._rev = results[:rev]
      data.updated_at = data[:updated_at] if data.has_key?(:updated_at)
      data.as_hash.update(new_data.as_hash)
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

    results = Couch_Doc.delete( data.id, data._rev )
    @data = nil # Mark document as new.

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

    if not new_data?
      raise Nothing_To_Update, "No new data to save."
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
    new_clean_value(
      field,
      raw_data[field]
    )
  end

  def sanitize &blok
    field = validator_field_name
    val   = cleanest( field ) 
		
		if val.is_a?(String)
			def val.with regexp, &blok
				gsub regexp, &blok
			end
		end
		
    new_clean_value(
      field, 
      raw_data[field].instance_eval(&blok)
    )
  end

  def must_be perfect = false, &blok
    begin
      vald = Couch_Plastic_Validator.new( self, validator_field_name, perfect, &blok )
      new_clean_value(
        validator_field_name,
        vald.clean_value
      )
    rescue Couch_Plastic_Validator::Invalid
    end
  end

  def must_be! &blok
    must_be(true, &blok)
  end

  # ==== Validator ====
  
  def lang_validator
    must_be! { 
      in_array LANGS.keys
    }
  end


end # === module Couch_Plastic ================================================



# =========================================================
# === Module: Class Methods for Couch_Plastic 
# ========================================================= 

module Couch_Plastic_Class_Methods 

  def assert_field field
    return true if fields.include?(field) || proto_fields.include?(field)
  end

  def fields 
    @fields ||= [:_id, :data_model, :_rev]
  end

  def proto_fields
    @proto_fields ||= []
  end

  # ===== DSL-icious ======
    
  def allow_proto_fields *args
    args.flatten.each { |fld|
      proto_fields << fld
    }
    @proto_fields.uniq!
    @proto_fields
  end

  def allow_fields *args
    args.each { |fld|
      fields << fld
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
		new( id )
  end

  def create editor, raw_raw_data # CREATE
    d = new(nil, editor, raw_raw_data)
    if !d.creator?(editor)
      raise d.class::Unauthorized_Creator.new(d,editor)
    end
    d.save_create 
    d
  end

  def read id, mem # READ
    d = by_id(id)
    if !d.reader?(mem)
      raise Unauthorized_Reader.new(d,mem)
    end
    d
  end

  def edit id, mem # EDIT
    d = new(id)
    if !d.updator?(mem)
      raise Unauthorized_Editor.new(d,mem)
    end
    d
  end

  def update id, editor, new_raw_data # UPDATE
		doc = new(id, editor, new_raw_data)
		if !doc.updator?(editor)
			raise Unauthorized_Updator.new(doc,editor)
		end
    doc.save_update 
    doc
  end

  def delete! id, editor # DELETE
		doc = new(id, editor)
    if !doc.deletor?(editor)
      raise Unauthorized_Deletor.new(doc, editor)
    end
    doc.delete!
    doc
  end


end # === module ClassMethods ==============================================




class Couch_Plastic_Validator

  Invalid = Class.new(StandardError)
  Perfection_Required = Class.new(StandardError)

  attr_reader :doc, :field_name, :english_field_name

  def initialize new_doc, new_field_name, perfect, &blok
    @doc                = new_doc
    @field_name         = new_field_name.to_sym
    @english_field_name = new_doc.human_field_name(@field_name).capitalize
    @must_be_perfect    = perfect
    @clean_val          = @doc.cleanest(@field_name)
    instance_eval(&blok)
  end

  def must_be_perfect 
    @must_be_perfect = true
  end

  def must_be_perfect?
    !!@must_be_perfect
  end

  def record_error new_msg
    msg = if new_msg['%']
            (new_msg % english_field_name)
          else
            new_msg
          end
    raise( Perfection_Required, msg ) if must_be_perfect?
    doc.errors << msg
    raise Invalid, "Error found on #{field_name}"
  end

  def clean_val *args
    return @clean_val if args.empty?
    return(@clean_val = args.first) if args.size === 1
    raise "What?!"
  end
  alias_method :clean_value, :clean_val


  # ======== Methods for validation.

  def stripped regexp = nil, &blok
    if clean_val.nil?
      record_error '%s is required.'
      return
    end

    new_val = clean_val.strip
    if regexp 
      new_val = if block_given?
                  clean_val.gsub(regexp, &blok)
                else
                  clean_val.gsub(regexp, '')
                end
    end
    clean_val( new_val )
  end
	
	def datetime_or_now
		if clean_val.nil?
			clean_val( Couch_Plastic.utc_now )
		else
			clean_val( Couch_Plastic.utc_string( clean_val ) )
		end
	end

  def not_empty
    stripped if clean_val.is_a?(String)

    if clean_val.nil? || clean_val.empty?
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




