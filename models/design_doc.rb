

class DesignDoc

  ID = '_design/megauni'
  URL = File.join(DB_CONN, ID)

  def self.doc
    begin
      JSON.parse(RestClient.get(URL)).symbolize_keys
    rescue RestClient::ResourceNotFound 
      nil
    end
  end

  def self.create_or_update
    return( doc ? update : create )
  end

  def self.create
    JSON.parse(RestClient.put( URL, as_json)).symbolize_keys
  end

  def self.update
    new_doc = doc.update(as_hash)

    JSON.parse(RestClient.put( URL, new_doc.to_json)).symbolize_keys
  end

  def self.as_hash
    doc = {:views=>{}}

    
    doc[:views][:by_tag] = {
      "map" => "
        function(doc) { 
          if (doc.data_model == 'News')  
            for(var t in doc.tags)
              emit([doc.tags[t], doc.published_at], null);
        }
      "
    }
          
        
    doc
  end

  def self.as_json
    as_hash.to_json
  end

end # === class DesignDoc

