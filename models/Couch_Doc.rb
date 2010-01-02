require 'rest_client'
require 'helpers/app/json'

class Couch_Doc
  
	HTTP_Error                     = Class.new(StandardError)
	HTTP_Error_409_Update_Conflict = Class.new(HTTP_Error)
	No_Doc_Found                   = Class.new(StandardError)

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
        raise Couch_Doc::No_Doc_Found, "No document found for: #{url}"
      else
        raise $!
      end

    rescue RestClient::RequestFailed
      
      msg = "#{$!.message}: SENT: #{http_meth} #{url} #{headers.inspect} RESPONSE: #{$!.response.body} "
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
      results[:rows].first
    else
      results[:rows]
    end

  end

  # =================== Design Doc methods ===================


  def GET_design
    begin
      GET( design_id )
    rescue Couch_Doc::No_Doc_Found 
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
    return true if create_design?
    
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
    doc = {:views=>{}}

    Dir.glob('helpers/couchdb_views/*.js').map { |file|
      v = File.basename(file).gsub('.js', '').gsub('-reduce.js', '').to_sym
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


