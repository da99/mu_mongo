
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
    rows = Couch_Doc.GET(:news_tags, :reduce=>true, :group=>true)[:rows]
    rows.map { |r| 
      r[:key]
    }
  end

  def self.by_tag tag, raw_params={}
    params = {:include_docs=>true, :startkey=>[tag, nil], :endkey=>[tag, {}]}.update(raw_params)
    Couch_Doc.GET(:news_by_tag, params)
  end

  def self.by_published_at raw_params={}
    # time_format = '%Y-%m-%d %H:%M:%S'
    # dt = Time.now.utc
    # start_dt = dt.strftime(time_format)
    # end_dt   = (dt + (60 * 60 * 24)).strftime(time_format)
    params = {:include_docs =>true}.update(raw_params)
    Couch_Doc.GET(:news_by_published_at, params)
  end

  # ==== Hooks =====================================================

  def before_create
    new_data.tags = []
    demand :title, :body, :published_at 
    ask_for :teaser, :tags 
  end

  def before_update
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

  def published_at
    data.published_at.to_time
  end

	def last_modified_at
		latest = [data.created_at, data.updated_at, data.published_at].compact.sort.first
		latest.to_time
	end

  # ==== Validators =====================================================

  def title_validator 
    new_data.title = clean(:title) {
      strip 
      must_not_be_empty
    }
  end # === 

  def teaser_validator
    return nil unless teaser.empty?
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
