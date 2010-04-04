
require 'mongo'

class Couch_Plastic
  
  Not_Found                      = Class.new(StandardError)
  HTTP_Error                     = Class.new(StandardError)
  HTTP_Error_409_Update_Conflict = Class.new(HTTP_Error)
  TIME_BASE = 1263487773
  CHARS = ["a", "l", 2, "t", "j", "w", "r", "d", "t", "j", 4, "d", 
          "z", "y", "w", "x", "m", "e", 1, "n", "s", "i", "g", "b", "b", "a", 
          8, "m", "u", "p", "v", "g", 7, "c", 5, "f", "k", "h", "z", 3, "v", 
          "o", "k", "h", "x", "y", 9, "i", "n", "l", "e", "q", "q", "u", "c", 
          "f", "r", "p", "s", "o", 6].map(&:to_s)

  ValidQueryOptions = %w{ 
      key
      startkey
      startkey_docid
      endkey
      endkey_docid
      limit
      stale
      descending
      skip
      group
      group_level
      reduce
      include_docs 
  }.map(&:to_sym)


  attr_reader :url_base, :design_id, :host, :db_name

  def initialize host, db_name, new_design = nil
    default_design = ('_design/' + File.basename(File.expand_path('.')))
    @db_name       = db_name
    @host          = host
    @url_base      = File.join(host, db_name)
    @design_id     = (new_design || default_design)
  end

  def send_to_db http_meth, raw_path, raw_data = nil, raw_headers = {}
    path    = raw_path.to_s
    url     = path['_uuid'] ? File.join(@host, path) : File.join( url_base, path )
    data    = raw_data ? raw_data.to_json : ''
    headers = { 'Content-Type'=>'application/json' }.update(raw_headers)
    
    begin
      client_response = case http_meth
        when :GET
          RestClient.get   url  
        when :POST
          RestClient.post  url, data, headers  
        when :PUT
          RestClient.put   url, data, headers  
        when :DELETE
          RestClient.delete  url, headers  
        else
          raise "Unknown HTTP method: #{http_meth.inspect}"
      end

      json_parse client_response.body

    rescue RestClient::ResourceNotFound 
      if http_meth === :GET
        raise Couch_Plastic::Not_Found, "No document found for: #{url}"
      else
        raise $!
      end

    rescue RestClient::RequestFailed
      
      msg = "
        #{$!.message}: 
        SENT: #{http_meth} #{url} #{headers.inspect} 
        RESPONSE: #{$!.response.body} 
        DATA: #{data.inspect}
      ".strip.split("\n").map(&:strip).join(" ")
      err = if $!.http_code === 409 && $!.http_body =~ /update conflict/ 
        HTTP_Error_409_Update_Conflict.new(msg)
      else
        HTTP_Error.new(msg)
      end

      raise err
      
    end
    
  end


  # === Main methods ===

  # Used for both creation and updating.
  def PUT doc_id, obj 
    send_to_db :PUT, doc_id, obj
  end

  def POST doc_id, obj
    send_to_db :POST, doc_id, obj
  end

  def DELETE doc_id, rev
    send_to_db :DELETE, doc_id, nil, {'If-Match' => rev}
  end

  def bulk_DELETE doc_arr
    data = doc_arr.map { |doc|
      { :_id      => doc[:_id], 
        :_rev     => doc[:_rev], 
        :_deleted => true 
      }
    }
    POST( '_bulk_docs', data)
  end

  def GET(path, params = {})

    return(send_to_db(:GET, path)) if params.empty?

    invalid_options = params.keys - ValidQueryOptions
    if !invalid_options.empty?
      raise ArgumentError, "Invalid options: #{invalid_options.inspect}" 
    end
    
    params_str = params.to_a.map { |kv|
      "#{kv.first}=#{CGI.escape(kv.last.to_json)}"
    }.join('&')
    
    send_to_db :GET, "#{path}?#{params_str}"

  end

  
  # === GET specific methods ===

  def GET_uuid
    GET( '_uuids' )[:uuids].first
  end

  def GET_psuedo_uuid
    (Time.now.utc.to_i - TIME_BASE).to_s(36) 
  end

  def GET_by_view(view_name, params={})

    view_must_exist! view_name

    # Check to see if :reduce option is needed.
    # :reduce parameter needs to be set by default 
    # since View may change in the future from 
    # 'map' to 'map/reduce'.
    if view_has_reduce?(view_name) && 
       !params.has_key?(:reduce)
       params[:reduce] = false 
    end

    path    = File.join(design_id, '_view', view_name.to_s)
    results = GET(path, params)

    return results if !params[:include_docs]
    
    if params[:limit] == 1
      first_row = results[:rows].first
      if not first_row
        raise Couch_Plastic::Not_Found, "No Results for: VIEW: #{view_name.inspect}, PARAMS: #{params.inspect}"
      end
      first_row
    else
      results[:rows]
    end

  end

  # =================== Design Doc methods ===================


  def GET_design
    begin
      GET( design_id )
    rescue Couch_Plastic::Not_Found 
      nil
    end
  end

  def design
    @cached_from_db ||= GET_design()
  end
  
  def create_or_update_design
    return( create_design ) if create_design?
    return( update_design ) if update_design?
    false
  end

  def create_design?
    !design # return true if no design exists
  end

  def update_design?
    return false if !design
    
    old_doc = design
    new_doc = design_on_file
    
    diff = begin
      new_doc[:views].detect { |(k,v)|
        old_doc[:views][k] != v
      }
    end

    !!diff
  end

  def create_design
    PUT( design_id, design_on_file )
  end

  def update_design
    new_doc = GET_design().update(design_on_file)
    PUT( design_id, new_doc )
  end

  def view_exists? view_name
    design[:views].has_key? view_name
  end
  
  def view_must_exist! view_name
    return true if view_exists?(view_name)
    raise ArgumentError, "View not found: #{view_name.inspect}"
  end

  def view_has_reduce?(view_name)
    view_must_exist! view_name
    design[:views][view_name].has_key?(:reduce)
  end

  def design_on_file
    doc = {:views=>{}, :filters=>{}}

    Dir.glob('helpers/couchdb_views/views/*.js').map { |file|
      v = filename_to_sym(file)

      doc[:views][v] ||= {}
      doc[:views][v][:map] = read_view_file("views/#{v}")

      begin
        doc[:views][v][:reduce] = read_view_file("views/#{v}-reduce")
      rescue Errno::ENOENT
      end
    }

    Dir.glob('helpers/couchdb_views/filters/*.js').map { |file|
      hash_index = File.basename(file)
      v = filename_to_sym(file)
      doc[:filters][v] = read_view_file("filters/#{v}")
    }
        
    doc
  end

  
  private # ===================================================

  def filename_to_sym str
    File.basename(str).sub( %r!\.js\Z!, '').sub(%r!-reduce\Z!, '').to_sym
  end
          
  # Parameters:
  #   view_name - Name of file w/o extension. E.g.: map-by_tag
  def read_view_file view_name
    File.read( 
      File.expand_path( 
        "helpers/couchdb_views/#{view_name}.js" 
      )
    ) 
  end


end #  == class Couch_Plastic =====================================





require 'loofah'

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
  
  attr_reader :data, :new_data, :raw_data, :clean_data, :assoc_cache, :manipulator

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
  def initialize *args, &blok
    
    super()
    
    @manipulator = nil
    @clean_data  = {}
    @assoc_cache = {}
    doc_id_or_hash = args.shift
    @manipulator = args.shift
    @raw_data    = (args.shift || {})
    @orig_doc    = case doc_id_or_hash
                     when String
                       self.class.db_collection.find(:_id=>Mongo::ObjectID.from_str(doc_id_or_hash))
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
        @equals = @fields.keys.inject({}) { |m, k| m["#{k}=".to_sym] = k; m }
      end

      def include?(key)
        as_hash.has_key?(key)
      end
    
      def as_hash
        (@doc.instance_variable_get :@orig_doc ) || {}
      end

      def respond_to? raw_meth
        meth = raw_meth.to_sym
        @fields.keys.include?(meth) || super(meth)
      end
    
      def method_missing( raw_key, *args )
        key = raw_key.to_sym
        if @equals[key]
          return(as_hash[@equals[key]] = args.first)
        end
        return(as_hash[key]) if @fields.keys.include?(key)
        raise NoMethodError, "#{raw_key.inspect} is not defined, nor is it a key."
      end
    }.new(self)
      
      
    @new_data = Class.new {
        
        def initialize( doc )
          @doc    = doc
          @keys   = doc.class.fields.keys
          raw_hash   = (doc.instance_variable_get :@orig_doc ) || {}
          @hash   = raw_hash.dup
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
          
          if @equals[key]
            return( as_hash[@equals[key]] = args.first )
          end
          
          raise NoMethodError, "#{raw_key.inspect} is not defined, nor is it a key."
        end
        
    }.new(self)

    if block_given?
      instance_eval(&blok)
    end

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

  def ask_for_or_default *args
    args.each { |raw_fld|
      fld = raw_fld.to_sym
      if raw_data.has_key?(fld)
        demand fld
      else
        send("#{fld}_default")
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
        
        val_method = "#{fld}_validator"
        if respond_to?(val_method)
          begin
            send(val_method)
          rescue Invalid
          end
        else
          self.class.fields[fld][:require].each { |reg| 
            case reg
            when :not_empty
              if !raw_data[fld] || raw_data[fld].empty?
                self.errors << "#{fld.to_s.capitalize} is required."
              else
                self.new_clean_value(fld, raw_data[fld])
              end
            else
              raise ArgumentError, "#{reg.inspect} is an invalid validation requirement."
            end
          }
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
    return nil unless self.class.fields.keys.include?(:created_at)
    data.created_at.to_time
  end

  def updated_at
    return nil unless self.class.fields.keys.include?(:updated_at)
    return nil if data.updated_at.nil?
    data.updated_at.to_time
  end
  
  
  # =========================================================
  #            Methods Related to DSL for Editors
  # ========================================================= 

  # =========================================================
  #               Save & Delete Methods
  # ========================================================= 

  def clean_hash hsh
    hsh.to_a.inject({}) { |m, (k, v)| 
      m[k] = case v
             when String
               Loofah::Helpers.strip_tags(v)
             when Array
               v.map { |val| Loofah::Helpers.strip_tags(val) }
             when Hash
               clean_hash(v)
             end
      m
    }
  end

  # Accepts an optional block that is given, if any, a RestClient::RequestFailed
  # exception.  Use ".response.body" on the exception for JSON data.
  # Parameters:
  #   opts - Valid options: :set_created_at
  def save_create *opts

    raise "This is not a new document." if !new?

    clear_assoc_cache
    
    if !(creator? manipulator)
      raise Unauthorized_Creator.new(self , manipulator)
    end
    
    raise_if_invalid

    new_data.data_model = self.class.name
    new_data.created_at = Couch_Plastic.utc_now if self.class.fields.include?(:created_at)
    vals                = clean_hash(new_data.as_hash.clone)

    err = begin
      @orig_doc = vals
      @orig_doc[:_id] = self.class.db_collection.insert( vals )
      nil
    rescue Object
      $!
    end

    return :ok unless err
    
    results = if block_given?
                yield err
              end
    raise err if not results

    self
  end

  # Accepts an optional block that is given, if any, a RestClient::RequestFailed
  # exception.  Use ".response.body" on the exception for JSON data.
  # Parameters:
  #   opts - Valid options: :set_updated_at
  def save_update *opts

    clear_assoc_cache
    if !updator?(manipulator)
      raise Unauthorized_Updator.new(self,manipulator)
    end
    raise_if_invalid

    insert = self.data.as_hash.clone.update(new_data.as_hash)
    insert[:_rev] = self.data._rev
    insert[:updated_at] = Time.now.utc if self.class.fields.include?(:updated_at)
    insert = clean_hash(insert)

    begin
      doc_id = self.class.db_collection( {:_id=>ObjectID.from_string(data._id)}, insert )
      data.updated_at = insert[:updated_at] if insert.has_key?(:updated_at)
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

    results = Couch_Plastic.delete( data.id, data._rev )
    @data = nil # Mark document as new.

  end

  # =========================================================
  #                  Validator Helpers
  # ========================================================= 

  def lang_default
    new_clean_value :lang, (@manipulator && @manipulator.lang) || 'en-us'
  end

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
    val   = raw_data[ field ] 
    
    if val.is_a?(String)
      def val.with regexp, &blok
        gsub regexp, &blok
      end
      def val.split_and_flatten dividors = ["\n", ',']
        dividors.inject(self.split(dividors.shift)) { |m, div|
          m.flatten.map { |piece| piece.split div}.flatten.map(&:strip)
        }.reject(&:empty?)
      end
    end
    
    new_clean_value(
      field, 
      val.instance_eval(&blok)
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

  def strip_class_name str
    str.sub(self.name.downcase + '-', '')
  end

  def assert_field field
    return true if fields.include?(field) || proto_fields.include?(field)
  end

  def fields 
    @fields ||= {:_id => {}, :data_model => {}, :_rev => {}, :lang => {} }
  end

  def allowed_field? fld
    @fields.keys.include? fld
  end

  def proto_fields
    @proto_fields ||= {}
  end

  # ===== DSL-icious ======
    
  def allow_proto_fields *args
    args.each { |fld|
      allow_proto_field fld
    }
  end

  def allow_proto_field title, default = nil, &validator
    define_method("#{title}_validator", &validator) if validator
    proto_fields[title] = {:default => default}
  end

  def allow_fields *args
    args.each { |fld|
      allow_field(fld)
    }
  end

  def allow_field title, default = nil, &validator
    define_method("#{title}_validator", &validator) if validator
    fields[title] = {:default => default}
  end

  def make name, *regs
    allow_field name
    fields[name][:require] = regs
  end

  def enable_timestamps
    allow_fields :created_at, :updated_at
  end

  def enable_created_at
    allow_fields :created_at
  end

  def timestamps_enabled?
    allowed_field?(:created_at) && allowed_field?(:updated_at)
  end


  # ===== CRUD Methods ====================================

  def by_id( id ) # READ
    new( id )
  end

  def create editor, raw_raw_data # CREATE
    d = new(nil, editor, raw_raw_data) do
      save_create 
    end
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
    doc = new(id, editor, new_raw_data) do
      save_update 
    end
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
    @clean_val          = @doc.new? ? @doc.cleanest(@field_name) : @doc.raw_data[@field_name]
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

  def strip_if_string
    stripped if clean_val.respond_to?(:strip)
  end

  def downcase
    clean_val(clean_val.downcase) if clean_val.respond_to?(:downcase)
  end

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

  def nil_if_empty
    if clean_val.respond_to?(:strip)
      stripped
    end

    if clean_val.empty?
      clean_val(nil)
    end
  end
  
  def datetime_or_now
    if clean_val.nil?
      clean_val( Couch_Plastic.utc_now )
    else
      clean_val( Couch_Plastic.utc_string( clean_val ) )
    end
  end

  def not_empty
    strip_if_string

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

  def array err_msg = nil
    if not clean_val.is_a?(Array)
      record_error( err_msg || '%s is_invalid.' )
    end
  end

  def anything 
  end

end # === Couch_Plastic_Validator


