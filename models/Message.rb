

class Message

  include Couch_Plastic

  enable_timestamps
  
  allow_fields :rating,
               :privacy

  allow_field :owner_id do
    must_be { not_empty }
  end

  allow_field :target_ids do
    must_be { 
      not_empty 
      array
    }
  end

  allow_field :body do
    must_be { not_empty }
  end

  allow_field :emotion do 
    must_be { not_empty }
  end

  allow_field :category do
    must_be { not_empty }
  end

  allow_field :labels do
    must_    sanitize {
      split("\n").
      map(&:strip).
      reject(&:empty?)
    }
    be { array }
  end

  allow_field :public_labels do
    must_be { array }
  end

  allow_field :title do
    must_be { not_empty }
  end # === 

  allow_field :teaser do
    accept_anything
  end # ===

  allow_field :published_at do
    must_be {
      datetime_or_now
    }
  end

  # ==== Authorizations ====
 
  def creator? editor # NEW, CREATE
    return false if !editor
    editor.has_power_of? :ADMIN
  end

  def self.create editor, raw_data
    d = new(nil, editor, raw_data) do
      new_data.labels = []
      new_data.public_labels = []
      ask_for_or_default :lang
      demand :owner_id, :target_ids, :body
      ask_for :category, :privacy, :labels,
          :question, :emotion, :rating,
          :labels, :public_labels
      save_create
    end
  end

  def reader? editor # SHOW
    true
  end

  def updator? editor # EDIT, UPDATE
    true
  end

  def self.update editor, raw_data
    ask_for :title, :body, :teaser, :published_at, :tags
  end

  def deletor? editor # DELETE
    true
  end

  # ==== Accessors ====

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

  # ==== Accessors =====================================================

  def published_at
    data.published_at.to_time
  end

	def last_modified_at
		latest = [data.created_at, data.updated_at, data.published_at].compact.sort.first
		latest.to_time
	end

end # === end Message
