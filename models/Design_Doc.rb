

class Design_Doc

  Views = %w{
    news_by_tag
    news_by_published_at
    news_tags
    member_usernames
  }.map(&:to_sym)

  ID = '_design/megauni'

  def self.from_db
    begin
      Couch_Doc.GET_by_id ID
    rescue Couch_Doc::No_Record_Found 
      nil
    end
  end

  def self.cached_from_db
    @cached_from_db ||= from_db
  end

  def self.needs_push_to_db?
    newest_doc = from_file_system
    old_doc    = from_db
    return true if !old_doc
    
    docs_match = begin
      [true] == newest_doc[:views].keys.map { |k|
        old_doc[:views][k] == newest_doc[:views][k]
      }.uniq
    end

    !docs_match
  end
  
  def self.create_or_update
    return( from_db ? update : create )
  end

  def self.create
    Couch_Doc.PUT ID, from_file_system
  end

  def self.update
    new_doc = from_db.update(from_file_system)
    Couch_Doc.PUT ID, new_doc
  end

  def self.view_exists? view_name
    cached_from_db[:views].has_key? view_name
  end

  def self.view_has_reduce?(view_name)
    if !view_exists?(view_name)
      raise ArgumentError, "View not found: #{view_name.inspect}"
    end
    cached_from_db[:views][view_name].has_key?(:reduce)
  end

  def self.from_file_system
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

end # === class Design_Doc

