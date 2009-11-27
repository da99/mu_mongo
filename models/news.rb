
require 'time' # To use Time.parse.

class News 

  include CouchPlastic

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

  setter( :create ) {
    demand :title, :body, :published_at 
    ask_for :teaser, :tags 
  }

  setter( :update ) {
    ask_for :title, :body, :teaser, :published_at, :tags
  }

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
    Time.parse( original_data[:created_at] )
  end

  def updated_at
    return nil if !original_data[:updated_at] || original_data[:updated_at].empty?
    Time.parse( original_data[:updated_at] )
  end

  def published_at
    Time.parse(original_data[:published_at])
  end

  def tags
    return [] if !original_data[:tags]
    super
  end

  # ==== Validators =====================================================

  validator :title do 
    strip 
    must_not_be_empty
  end # === 

  validator :teaser do 
    strip
    dont_set_if {
      teaser.empty?
    }
  end # ===

  validator :body do
    strip
    must_not_be_empty
  end # ===

  validator :published_at do
    to_datetime_or_now
  end

  validator :tags do
    split
    dont_set_if { tags.empty? }
  end

end # === end News
