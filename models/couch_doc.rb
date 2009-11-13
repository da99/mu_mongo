
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
    results = rest_call {
      RestClient.get( File.join( CouchDB_URI, '_uuids') )
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
    raise ArgumentError, "Invalid id: #{id.inspect}" if !id
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
    url = File.join(DB_CONN, doc_id.to_s)
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


end #  == class CouchDoc =====================================


