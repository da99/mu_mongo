
class CouchDoc
  
  class HTTP_Error < StandardError; end

  Views = %w{
    news_by_tag
    news_by_published_at
    news_tags
    usernames_by_owner
  }

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


  def self.rest_call 
    results = begin
      yield
    rescue RestClient::RequestFailed
      raise HTTP_Error, "#{$!.http_code} - #{$!.http_body}"
    end

    json_parse results
  end

  def self.GET_uuid
    url_pieces = DB_CONN.split('/')
    url_pieces.pop
    url_pieces.push '_uuids'
    results = rest_call {
      RestClient.get( url_pieces.join('/') )
    }
    results[:uuids].first
  end

  def self.GET_naked(path, params = {})

    db_url = File.join(DB_CONN, path.to_s) 
    
    if params.empty?
      return( 
        rest_call { 
          RestClient.get( db_url ) 
        } 
      )
    end

    invalid_options = params.keys - ValidQueryOptions
    if !invalid_options.empty?
      raise ArgumentError, "Invalid options: #{invalid_options.inspect}" 
    end
    
    params_str = params.to_a.map { |kv|
      "#{kv.first}=#{CGI.escape(kv.last.to_json)}"
    }.join('&')
    
    rest_call {
      RestClient.get(db_url + '?' + params_str)
    }

  end

  def self.GET_by_id(id)

    begin
      data = GET_naked( id )
      return(data) if !data[:data_model]
      doc = Object.const_get(data[:data_model]).new
      doc._set_original_(data)
    rescue RestClient::ResourceNotFound 
      raise CouchPlastic::NoRecordFound, "Document with id, #{id}, not found."
    end

    doc

  end

  def self.GET(view_name, params={})
    if !Views.include?(view_name.to_s)
      raise ArgumentError, "Non-existent view name: #{view_name}"
    end

    path                  = File.join(DESIGN_DOC_ID, '_view', view_name.to_s)
    results               = GET_naked(path, params)

    return results if !params[:include_docs]

    objs = results[:rows].inject([]) { |m,r|
      doc = Object.const_get(r[:doc][:data_model]).new
      doc._set_original_(r[:doc])
      m << doc
      m
    }
    if params[:limit] == 1
      objs.first
    else
      objs
    end
  end

  # Used for both creation and updating.
  def self.PUT( doc_id, obj)
    url = File.join(DB_CONN, doc_id)
    rest_call { 
      RestClient.put( url, obj.to_json ) 
    }
  end

  def self.DELETE doc_id, rev
    rest_call {
      RestClient.delete(
        File.join(DB_CONN, doc_id.to_s), 
        'If-Match' => rev 
      )
    }
  end

  # =========================================================
  #                   View-related GET-ters
  # ========================================================= 


  def self.GET_news_tags
    GET(:news_tags, :reduce=>true, :group=>true)[:rows].map { |r| 
      r[:key]
    }
  end

  def self.GET_news_by_tag tag, raw_params={}
    params = {:include_docs=>true, :startkey=>[tag, nil], :endkey=>[tag, {}]}.update(raw_params)
    GET(:news_by_tag, params)
  end

  def self.GET_news_by_published_at raw_dt, raw_params={}
    time_format = '%Y-%m-%d %H:%M:%S'
    dt = Time.now.utc
    start_dt = dt.strftime(time_format)
    end_dt   = (dt + (60 * 60 * 24)).strftime(time_format)
    params = {:include_docs =>true, :startkey=>start_dt, :endkey=>end_dt}.update(raw_params)
    GET(:news_by_published_at, params)
  end

  def self.GET_usernames_by_owner owner_id
    results = GET(:usernames_by_owner, :key=> owner_id.to_s, :include_docs=>false)
    results[:rows].map { |r| r[:value] }
  end

end #  == class CouchDoc =====================================



module CouchPlastic
  

  # =========================================================
  #                     Error Constants
  # ========================================================= 

  class NoRecordFound < StandardError; end
  class UnauthorizedEditor < StandardError; end
  class Invalid < StandardError; end
  class NoNewValues < StandardError; end
  class HTTPError < StandardError; end
  
  
  # =========================================================
  #                  Module: ClassMethods
  # ========================================================= 
  
  module ClassMethods # =======================================
  end # === ClassMethods

 
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
 

  def _before_save_
    clear_assoc_cache
    validate
  end

  # Accepts an optional block that is given, if any, a RestClient::RequestFailed
  # exception.  Use ".response.body" on the exception for JSON data.
  # Parameters:
  #   opts - Valid options: :set_created_at
  def save_create *opts
    
    _before_save_

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

  # Accepts an optional block that is given, if any, a RestClient::RequestFailed
  # exception.  Use ".response.body" on the exception for JSON data.
  # Parameters:
  #   opts - Valid options: :set_updated_at
  def save_update *opts

    _before_save_

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

  def delete!
    
    clear_assoc_cache

    begin
      results = CouchDoc.delete( original[:id], original[:_rev] )
      original.clear # Mark document as new.
    rescue RestClient::ResourceNotFound
      true
    end

  end
  



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
      raise Invalid, "Document has validation errors." 
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













