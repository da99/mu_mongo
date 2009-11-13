

class DesignDoc

  ID = '_design/megauni'

  def self.doc
    begin
      CouchDoc.GET_by_id ID
    rescue CouchPlastic::NoRecordFound 
      nil
    end
  end

  def self.create_or_update
    return( doc ? update : create )
  end

  def self.create
    CouchDoc.PUT ID, as_hash
  end

  def self.update
    new_doc = doc.update(as_hash)
    CouchDoc.PUT ID, new_doc
  end

  def self.as_hash
    doc = {:views=>{}}

    CouchDoc::Views.each { |v|
      doc[:views][v] ||= {}
      doc[:views][v][:map] = read_view_file(v)

      begin
        doc[:views][v][:reduce] = read_view_file("#{v}-reduce")
      rescue Errno::ENOENT
      end
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

