

class DesignDoc

  Views = %w{
    news_by_tag
    news_by_published_at
    news_tags
    member_usernames
  }.map(&:to_sym)

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
    CouchDoc.PUT ID, fresh_hash
  end

  def self.update
    new_doc = doc.update(fresh_hash)
    CouchDoc.PUT ID, new_doc
  end

  def self.view_exists? view_name
    as_hash[:views].has_key? view_name
  end

  def self.view_has_reduce?(view_name)
    if !view_exists?(view_name)
      raise ArgumentError, "View not found: #{view_name.inspect}"
    end
    as_hash[:views][view_name].has_key?(:reduce)
  end

  def self.as_hash
    @as_hash ||= fresh_hash
  end

  def self.fresh_hash
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

