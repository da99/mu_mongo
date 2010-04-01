

class Message

  include Couch_Plastic

  enable_timestamps
  
  allow_fields :rating

	allow_field :privacy do
		must_be { in_array(['private', 'public', 'friends_only']) }
	end

  allow_field :owner_id do
    must_be { 
			not_empty 
			in_array( doc.manipulator.username_ids )
		}
  end

  allow_field :target_ids do
    sanitize {
      if is_a?(String)
        split_and_flatten 
      else
        self
      end
    }
    must_be { 
      array
    }
  end

  make :body, :not_empty

  allow_field :emotion do 
    must_be { not_empty }
  end

  allow_field :category do
    must_be { not_empty }
  end

  allow_field :labels do
    sanitize {
      split_and_flatten
    }
    must_be { array }
  end

  allow_field :public_labels do
    sanitize {
      split_and_flatten
    }
    must_be { array }
  end

  allow_field :title do
    must_be { anything }
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
    # return false if !editor
    editor.has_power_of? :MEMBER
    # editor.has_power_of? :ADMIN
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
			new_data._id = "message-#{CouchDB_CONN.GET_psuedo_uuid}"
      
      save_create do |err|
        case err
        when Couch_Doc::HTTP_Error_409_Update_Conflict
          psuedo = new_data._id
          (0..99).to_a.detect { |i|
            begin
              new_data._id = "#{psuedo}-%02d" % i
              save_create
            rescue Couch_Doc::HTTP_Error_409_Update_Conflict
              false
            end
          }
        else
          raise err
        end
      end
    end
  end

  def reader? editor # SHOW
    true
  end

  def updator? editor # EDIT, UPDATE
    creator? editor
  end

  def self.update id, editor, new_raw_data
    doc = new(id, editor, new_raw_data) do
      ask_for :title, :body, :teaser, :public_labels, :private_labels, :published_at, :tags
      save_update
    end
  end

  def deletor? editor # DELETE
    true
  end

  # ==== Accessors ====

  def self.latest_by_club_id club_id, raw_params = {}
    params = {:include_docs=>true, :descending=>true, :limit=>10, :startkey=>[club_id, {}], :endkey=>[club_id]}.update(raw_params)
    CouchDB_CONN.GET_by_view(:messages_latest_by_club_id, params)
  end

	def self.public raw_params = {}
		params = {:include_docs=>true, :limit=>10}.update(raw_params)
		rows = CouchDB_CONN.GET_by_view(:messages_public, params)
	end

  def self.public_labels
    rows = CouchDB_CONN.GET_by_view(:messages_public_labels, :reduce=>true, :group=>true)[:rows]
    rows.map { |r| 
      r[:key]
    }
  end

  def self.by_public_label label, raw_params={}
    params = {:include_docs=>true, :key=>label}.update(raw_params)
    CouchDB_CONN.GET_by_view(:messages_by_public_label, params)
  end

  def self.by_club_id_and_public_label club_id, label, raw_params = {}
    params = {:include_docs=>true, :descending=>true, :startkey=>[club_id, label, {}], :endkey=>[club_id, label]}.update(raw_params)
    CouchDB_CONN.GET_by_view(:messages_by_club_id_and_public_label, params)
  end

  def self.by_published_at *args
    if args.size === 1
      raw_params=args.first
    else
      case args.size
      when 2
        start_year = args[0].to_i
        start_month = args[1].to_i
        case start_month
        when 12
          end_month = 1
          end_year = (start_year + 1)
        else
          end_month = start_month + 1
          end_year = start_year
        end
      when 4
        start_year, start_month, end_year, end_month = args
      else
        raise ArgumentError, "Unknown argument list: #{args.inspect}"
      end
      time_format = '%Y-%m-%d %H:%M:%S'
      raw_params = { 
        :startkey => Time.utc(start_year, start_month).strftime(time_format), 
        :endkey => Time.utc(end_year, end_month).strftime(time_format) 
      }

    end
    # time_format = '%Y-%m-%d %H:%M:%S'
    # dt = Time.now.utc
    # start_dt = dt.strftime(time_format)
    # end_dt   = (dt + (60 * 60 * 24)).strftime(time_format)
    params = {:include_docs =>true}.update(raw_params)
    CouchDB_CONN.GET_by_view(:messages_by_published_at, params)
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
    CouchDB_CONN.GET_by_view( :messages_by_club_id_and_published_at, params ).map { |post|
      post[:doc]
    }
  end

  # ==== Accessors =====================================================

  def published_at
    Time.parse(data.published_at || data.created_at)
  end

  def last_modified_at
    latest = [data.created_at, data.updated_at, data.published_at].compact.sort.first
    Time.parse(latest)
  end

end # === end Message
