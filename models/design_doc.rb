

class DesignDoc

  ID = '_design/megauni'
  URL = File.join(DB_CONN, ID)

  def self.doc
    begin
      json_parse(RestClient.get(URL))
    rescue RestClient::ResourceNotFound 
      nil
    end
  end

  def self.create_or_update
    return( doc ? update : create )
  end

  def self.create
    json_parse(RestClient.put( URL, as_hash.to_json))
  end

  def self.update
    new_doc = doc.update(as_hash)

    json_parse(RestClient.put( URL, new_doc.to_json))
  end

  def self.as_hash
    doc = {:views=>{}}

    CouchDoc::Views.each { |v|
      doc[:views][v] ||= {}
      doc[:views][v][:map] = read_view_file(v)
    }
        
    doc
  end

  # Parameters:
  #   view_name - Name of file w/o extension. E.g.: map-by_tag
  def self.read_view_file view_name
    File.read( 
      File.expand_path( 
        "helpers/couchdb_views/#{view_name}.js" 
      )
    ) 
  end

end # === class DesignDoc

