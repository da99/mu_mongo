require 'helpers/app/json'

class CouchDoc
  
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


  def self.rest_call 
    results = begin
      yield
    rescue RestClient::RequestFailed
			err = case $!.http_code
						when 409
							if $!.http_body =~ /update conflict/ 
								HTTP_Error_409_Update_Conflict
							else
								HTTP_Error
							end
						else
							HTTP_Error
						end
			raise err, "#{$!.http_code} - #{$!.http_body}"
    end

    json_parse results
  end

  def self.GET_uuid
    results = rest_call {
      RestClient.get( File.join( CouchDB_URI, '_uuids') )
    }
    results[:uuids].first
  end

  def self.GET_naked(path, params = {})

    db_url = File.join( ::DB_CONN, path.to_s) 
    
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
    raise ArgumentError, "Invalid id: #{id.inspect}" if !id
    begin
      data = GET_naked( id )
      return(data) if !data[:data_model]
      doc = Object.const_get(data[:data_model]).new_from_db(data)
    rescue RestClient::ResourceNotFound 
      raise CouchDoc::No_Record_Found, "Document with id, #{id}, not found."
    end

    doc

  end

  def self.GET(view_name, params={})

    if !DesignDoc.view_exists?(view_name)
      raise ArgumentError, "Non-existent view name: #{view_name.inspect}"
    end

    # Check to see if :reduce option is needed.
    # :reduce parameter needs to be set by default 
    # since View may change in the future from 
    # 'map' to 'map/reduce'.
    if !params.has_key?(:reduce)
      if DesignDoc.view_has_reduce?(view_name)
        params[:reduce] = false
      end
    end

    path    = File.join(DESIGN_DOC_ID, '_view', view_name.to_s)
    results = GET_naked(path, params)

    return results if !params[:include_docs]

    objs = results[:rows].inject([]) { |m,r|
      m << Object.const_get(r[:doc][:data_model]).new_from_db(r[:doc])
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
    url = File.join(DB_CONN, doc_id.to_s)
    rest_call { 
      RestClient.put( url, obj.to_json, {'Content-Type' => 'application/json'} ) 
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


end #  == class CouchDoc =====================================


