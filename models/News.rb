
class News 

  include Couch_Plastic

  enable_timestamps

  allow_fields :club_id,
               :title, 
               :teaser,
               :body,
               :tags,
               :published_at

  # ==== Getters =====================================================    
  
  def self.tags
    rows = CouchDB_CONN.GET_by_view(:news_tags, :reduce=>true, :group=>true)[:rows]
    rows.map { |r| 
      r[:key]
    }
  end

  def self.by_tag tag, raw_params={}
    params = {:include_docs=>true, :startkey=>[tag, nil], :endkey=>[tag, {}]}.update(raw_params)
    Couch_Doc.GET_by_view(:news_by_tag, params)
  end

  def self.by_published_at raw_params={}
    # time_format = '%Y-%m-%d %H:%M:%S'
    # dt = Time.now.utc
    # start_dt = dt.strftime(time_format)
    # end_dt   = (dt + (60 * 60 * 24)).strftime(time_format)
    params = {:include_docs =>true}.update(raw_params)
    CouchDB_CONN.GET_by_view(:news_by_published_at, params)
  end

  def self.by_club_id_and_published_at raw_params = {}
    club = raw_params.delete(:club) || {}
    if club.is_a?(String)
      club = "club-#{club.sub('club-', '')}"
    end
    params = { :startkey => [club],  
               :endkey   => [club, {}], 
               :include_docs => true
    }.update(raw_params)
    CouchDB_CONN.GET_by_view( :news_by_club_id_and_published_at, params ).map { |post|
      post[:doc]
    }
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
  alias_method :updator?, :creator?
  alias_method :deletor?, :creator?
  
  def reader? editor # SHOW
    true
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
    must_be { not_empty }
  end # === 

  def teaser_validator
    accept_anything
  end # ===

  def body_validator
    must_be { not_empty }
  end # ===

  def published_at_validator
    must_be {
      datetime_or_now
    }
  end

  def tags_validator
    sanitize {
      split("\n").
      map(&:strip).
      reject(&:empty?)
    }
  end

end # === end News
