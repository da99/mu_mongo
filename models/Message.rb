

class Message

  include Couch_Plastic

  enable_timestamps
  
  make :rating, :not_empty
	make :privacy, [:in_array, ['private', 'public', 'friends_only'] ]
  make :username_id, :mongo_object_id, [:in_array, lambda { manipulator.username_ids } ]
  make :target_ids, :split_and_flatten, :mongo_object_id_array
  make :body, :not_empty
  make :question, :not_empty
  make :emotion, :not_empty
  make :category, :not_empty
  make :labels, :split_and_flatten, :array
  make :public_labels, :split_and_flatten, :array
  make :private_labels, :split_and_flatten, :array
  make :title, :anything
  make :teaser, :anything
  make :published_at, :datetime_or_now

  # ==== Authorizations ====
 
  def creator? editor # NEW, CREATE
    editor.has_power_of? :MEMBER
  end

  def self.create editor, raw_data
    d = new do
      self.manipulator = editor
      self.raw_data = raw_data
      new_data.labels = []
      new_data.public_labels = []
      ask_for_or_default :lang
      demand :username_id, :target_ids, :body
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
    creator? editor
  end

  def self.update id, editor, new_raw_data
    doc = new(id) do
      self.manipulator = editor
      self.raw_data    = new_raw_data
      ask_for :title, :body, :teaser, :public_labels, 
				:private_labels, :published_at
      save_update
    end
  end

  def deletor? editor # DELETE
    true
  end

  # ==== Accessors ====

  def self.latest_by_club_id club_id, raw_params = {}, raw_opts = {}, &blok
    params = {:target_ids=>club_id}
    opts   = {:limit=>10, :sort=>[:_id, :desc]}
    db_collection.find(
			params.update(raw_params), 
			opts.update(raw_opts),
			&blok
		)
  end

	def self.public raw_params = {}, raw_opts = {}, &blok
		opts = {:limit=>10}.update(raw_opts)
		params = {}.update(raw_params)
    db_collection.find(
			params, 
      opts,
			&blok
		)
	end

  def self.public_labels target_ids = nil
    m = %~
      function () {
          for (var i in this.target_ids) {
              emit(this.target_ids[i], {total:1});
          }
      }    
    ~
    r = %~
      function (key, value) {
          var sum = 0;
          value.forEach(function (doc) {sum += doc.total;});
          return {total:sum};
      }
    ~
    opts = if target_ids
             { :query => { :target_ids=> { :$in=>target_ids}} }
           else
             {}
           end
    
    db_collection.map_reduce(m, r, opts).find().map { |r| r['_id'] }
  end

  def self.by_public_label label, raw_params={}, &blok
    params = { :public_labels => {:$in=>[label]} }.update(raw_params)
    db_collection.find( params, &blok )
  end

  def self.by_club_id_and_public_label club_id, label, raw_params = {}, raw_opts={}, &blok
    params = Hash.new( 
              :target_ids    => {:$in=>[club_id]},
              :public_labels => {:$in=>[label].flatten}
             ).update(raw_params)
    opts = {:sort=>[:_id, :desc]}.update(raw_opts)
    db_collection.find(params, &blok)
  end

  def self.by_published_at *args, &blok
    if args.size === 1
      raw_opts=args.first
      opts = {}.update(raw_opts)
      params = {}
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
      start_tm = Time.utc(start_year, start_month).strftime(time_format),
      end_tm   = Time.utc(end_year, end_month).strftime(time_format)
      params = {:published_at=>{'$gt'=>start_tm,'$lt'=>end_tm}}
      opts = {}
    end
    # time_format = '%Y-%m-%d %H:%M:%S'
    # dt = Time.now.utc
    # start_dt = dt.strftime(time_format)
    # end_dt   = (dt + (60 * 60 * 24)).strftime(time_format)
    db_collection.find(params, opts, &blok )
  end

  def self.by_club_id_and_published_at club_id, raw_params = {}, opts = {}, &blok
    db_collection.find(
			{:target_ids=>Club.filename_to_id(club_id)},
      opts, 
			&blok
    )
  end
  

  def self.by_old_id id
    old_id = "message-#{id}"
    mess = db_collection.find_one(:old_id=>old_id)
    if mess
      by_id(mess['_id'])
    else
      by_id(old_id)
    end
  end

  # ==== Accessors =====================================================

  def product?
    data.public_labels && data.public_labels.include?('product')
  end

  def published_at
    Time.parse(data.published_at || data.created_at)
  end

  def last_modified_at
    latest = [data.created_at, data.updated_at, data.published_at].compact.sort.first
    Time.parse(latest)
  end

end # === end Message
