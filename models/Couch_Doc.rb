require 'rest_client'
require 'helpers/app/json'

class Couch_Doc
  
  Views = Dir.glob('helpers/couchdb_views/*.js').map { |file|
            File.basename(file).gsub('-reduce.js', '').gsub('.js', '')
          }.uniq.map(&:to_sym)
          
	HTTP_Error                     = Class.new(StandardError)
	HTTP_Error_409_Update_Conflict = Class.new(HTTP_Error)
	No_Record_Found                = Class.new(StandardError)

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


	attr_reader :uri_base, :design_doc_id

	def initialize host, db_name, new_design = nil
    default_design = ('_design/' + File.basename(File.expand_path('.')))
		@url_base      = new_url
		@design_doc_id = (new_design || default_design)
	end

	def send_to_db http_meth, path, raw_data = nil, raw_headers = {}
		
    url     = File.join( url_base, path.to_s )
    data    = raw_data ? raw_data.to_json : ''
    headers = { 'Content-Type' => 'application/json' }.update(raw_headers)
    
    begin
      json_parse case http_meth
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

    rescue RestClient::ResourceNotFound 
      if http_meth === :GET
        raise Couch_Doc::No_Record_Found, "No document found for: #{path}"
      else
        raise $!
      end

    rescue RestClient::RequestFailed
      
      msg = "#{$!.http_code} #{$!.http_message}: #{$!.http_body}"
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
  def PUT( doc_id, obj)
    send_to_db :PUT, doc_id, obj
  end

  def DELETE doc_id, rev
    send_to_db :DELETE, doc_id, nil, {'If-Match' => rev}
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

  def GET_by_view(view_name, params={})

    if !Design_Doc.view_exists?(view_name)
      raise ArgumentError, "Non-existent view name: #{view_name.inspect}"
    end

    # Check to see if :reduce option is needed.
    # :reduce parameter needs to be set by default 
    # since View may change in the future from 
    # 'map' to 'map/reduce'.
    if Design_Doc.view_has_reduce?(view_name) && 
       !params.has_key?(:reduce)
       params[:reduce] = false 
    end

    path    = File.join(DESIGN_DOC_ID, '_view', view_name.to_s)
    results = GET(path, params)

    return results if !params[:include_docs]
    
    if params[:limit] == 1
      results[:rows].first
    else
      results[:rows]
    end

  end

  # =================== Design Doc methods ===================


  def GET_design
    begin
      GET( design_id )
    rescue Couch_Doc::No_Record_Found 
      nil
    end
  end

  def design
    @cached_from_db ||= GET_design()
  end

  def put_design?
    old_doc = GET_design()
    new_doc = design
    return true if !old_doc
    
    docs_match = begin
      [true] == new_doc[:views].keys.map { |k|
        old_doc[:views][k] == new_doc[:views][k]
      }.uniq
    end

    !docs_match
  end
  
  def create_or_update_design
    return( GET_design() ? update_design : create_design )
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

  def view_has_reduce?(view_name)
    if !view_exists?(view_name)
      raise ArgumentError, "View not found: #{view_name.inspect}"
    end
    design[:views][view_name].has_key?(:reduce)
  end

  def design_on_file
    doc = {:views=>{}}

    Views.each { |v|
      doc[:views][v] ||= {}
      doc[:views][v][:map] = read_view_file(v)

      begin
        doc[:views][v][:reduce] = read_view_file("#{v}-reduce")
      rescue Errno::ENOENT
      end
    }
        
    doc
  end

  private # ===================================================

  # Parameters:
  #   view_name - Name of file w/o extension. E.g.: map-by_tag
  def read_view_file view_name
    File.read( 
      File.expand_path( 
        "helpers/couchdb_views/#{view_name}.js" 
      )
    ) 
  end


end #  == class Couch_Doc =====================================


