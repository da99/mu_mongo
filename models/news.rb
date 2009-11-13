
require 'time' # To use Time.parse.

class News 

  include CouchPlastic


  # ==== GET Methods (Class) =================================================

  def self.get_tags
    rows = CouchDoc.GET(:news_tags, 
        :reduce=>true, 
       :group=>true)[:rows]
    rows.map { |r| 
      r[:key]
    }
  end

  def self.get_by_tag tag, raw_params={}
    params = {:include_docs=>true, :startkey=>[tag, nil], :endkey=>[tag, {}]}.update(raw_params)
    CouchDoc.GET(:news_by_tag, params)
  end

  def self.get_by_published_at raw_params={}
    # time_format = '%Y-%m-%d %H:%M:%S'
    # dt = Time.now.utc
    # start_dt = dt.strftime(time_format)
    # end_dt   = (dt + (60 * 60 * 24)).strftime(time_format)
    params = {:include_docs =>true}.update(raw_params)
    CouchDoc.GET(:news_by_published_at, params)
  end

  # ==== CRUD Methods ============================================================

  enable :created_at, :updated_at

  required_for_create  :title, :body, :published_at 
  optional_for_create  :teaser, :tags 

  optional_for_update :title, :body, :teaser, :published_at, :tags

  # ==== Authorization Methods (Class + Instance) =================================================
  
  def creator? editor # NEW, CREATE
    return false if !editor
    editor.has_power_of? :ADMIN
  end

  def viewer? editor # SHOW
    true
  end

  def updator? editor # EDIT, UPDATE
    creator? editor
  end

  def deletor? editor # DELETE
    creator? editor
  end


  # ==== SETTERS/ACCESSORS (Instance) ==============================================

  def last_modified_at
    updated_at || created_at
  end

  def created_at
    Time.parse( original[:created_at] )
  end

  def updated_at
    return nil if !original[:updated_at] || original[:updated_at].empty?
    Time.parse( original[:updated_at] )
  end

  def published_at
    Time.parse(original[:published_at])
  end

  def title= raw_data
    fn = :title
    new_title = raw_data[:title].to_s.strip
    if new_title.empty?
      self.errors << "Title must not be empty."
      return nil
    end
    self.new_values[:title] = new_title
  end # === 

  def teaser= raw_data
    new_teaser = raw_data[:teaser].to_s.strip
    if new_teaser.empty?
      new_values[:teaser] = nil
    else
      new_values[:teaser] = new_teaser 
    end
  end # ===

  def body= raw_data
    new_body = raw_data[:body].to_s.strip
    if new_body.empty?
      self.errors << "Body must not be empty."
    elsif new_body.length < 10
      self.errors << "Body is too short. Write more."
    end

    return nil if !self.errors.empty?

    new_values[:body] = new_body
  end # ===

  def published_at= raw_data
    self.new_values[:published_at] = Time.parse(raw_data[:published_at]) || Time.now.utc
  end

  def tags= raw_data
    new_tags = raw_data[:tags].to_s.split
    return nil if new_tags.empty?
    self.new_values[:tags] = new_tags
  end

end # === end News
