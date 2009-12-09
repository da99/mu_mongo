
require 'time' # To use Time.parse.

class News 

  include CouchPlastic

  enable_timestamps

  allow_fields :title, 
               :teaser,
               :body,
               :tags,
               :published_at

  # ==== Getters =====================================================    
  
  def self.tags
    rows = CouchDoc.GET(:news_tags, :reduce=>true, :group=>true)[:rows]
    rows.map { |r| 
      r[:key]
    }
  end

  def self.by_tag tag, raw_params={}
    params = {:include_docs=>true, :startkey=>[tag, nil], :endkey=>[tag, {}]}.update(raw_params)
    CouchDoc.GET(:news_by_tag, params)
  end

  def self.by_published_at raw_params={}
    # time_format = '%Y-%m-%d %H:%M:%S'
    # dt = Time.now.utc
    # start_dt = dt.strftime(time_format)
    # end_dt   = (dt + (60 * 60 * 24)).strftime(time_format)
    params = {:include_docs =>true}.update(raw_params)
    CouchDoc.GET(:news_by_published_at, params)
  end

  # ==== CRUD =====================================================

  enable_timestamps

  def setter_for_create
    new_data.tags = []
    demand :title, :body, :published_at 
    ask_for :teaser, :tags 
  end

  def setter_for_update
    ask_for :title, :body, :teaser, :published_at, :tags
  end

  # ==== Authorizations =====================================================
 
  def creator? editor # NEW, CREATE
    return false if !editor
    editor.has_power_of? :ADMIN
  end

  def reader? editor # SHOW
    true
  end

  def updator? editor # EDIT, UPDATE
    creator? editor
  end

  def deletor? editor # DELETE
    creator? editor
  end


  # ==== Accessors =====================================================

  def last_modified_at
    updated_at || created_at
  end

  def created_at
    Time.parse( original_data.created_at )
  end

  def updated_at
    return nil if !original_data.updated_at || original_data.updated_at.empty?
    Time.parse( original_data.updated_at )
  end

  def published_at
    Time.parse( data.published_at || data.created_at )
  end


  # ==== Validators =====================================================

  def title_validator 
    new_data.title = clean(:title) {
      strip 
      must_not_be_empty
    }
  end # === 

  def teaser_validator
    teaser = raw_data[:teaser].to_s.strip
    return nil if teaser.empty?
    new_data.teaser = teaser
  end # ===

  def body_validator
    new_data.body = clean :body do
      strip
      must_not_be_empty
    end
  end # ===

  def published_at_validator
    new_data.published_at = clean :published_at do
      to_datetime_or_now
    end
  end

  def tags_validator
    new_data.tags = clean_data[:tags] = raw_data[:tags].to_s.split.map(&:strip).reject(&:empty?)
  end

end # === end News
