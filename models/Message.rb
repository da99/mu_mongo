

class Message

  module SECTIONS
    E      = 'Encyclopedia'
    R      = 'Random'
    F      = 'Fights'
    PREDICTIONS = 'Predictions'
    RANDOM = 'RANDOM'
    MAG    = 'Magazine'
    NEWS   = 'News'
    QA     = 'Q & A'
    SHOP   = 'Shop'
    FIGHTS = 'Fights'
    THANKS = 'Thanks'
  end

  MODEL_HASH = {
    'news' => ['important news', SECTIONS::NEWS],
    'comment' => ['comment'],
    'random' => ['random info.', SECTIONS::R],
    'fight' => ['fight', SECTIONS::F],
    'debate' => ['friendly debate', SECTIONS::F],
    'complaint' => ['complaint', SECTIONS::F],
    'prediction' => ['prediction', SECTIONS::PREDICTIONS],
    'mag_story'  => ['magazine article', SECTIONS::MAG],
    'question'   => ['question', SECTIONS::QA],
    'cheer'      => ['cheer reply', SECTIONS::THANKS],
    'jeer'      => ['critique reply', SECTIONS::THANKS],
    'suggest'      => ['suggestion', SECTIONS::THANKS],
		'e_chapter' => ['encyclopedia chapter', SECTIONS::E],
		'e_quote' => ['quotation', SECTIONS::E],
    'buy'     => ['buy it', SECTIONS::SHOP],
    'thank'   => ['thanks', SECTIONS::THANKS]
    # quote
    # plea  
    # fulfill
    # discuss
    # answer
    # event
  }
  
  MODELS = MODEL_HASH.keys
  
  include Couch_Plastic

  enable_timestamps
  
  make_psuedo :editor_id, :mongo_object_id, [:in_array, lambda { manipulator.username_ids } ]

  make :message_model, [:in_array, MODELS]
  make :important, :not_empty
  make :rating, :not_empty
  make :privacy, [:in_array, ['private', 'public', 'friends_only'] ]
  make :owner_id, :mongo_object_id, [:in_array, lambda { manipulator.username_ids } ]
  make :parent_message_id, :mongo_object_id, [:set_raw_data, [:target_ids, lambda { 
    mess = Message.by_id(raw_data.parent_message_id)
    mess.data.target_ids
  }]]
  make :target_ids, :split_and_flatten, :mongo_object_id_array
  make :body, :not_empty
  make :body_images_cache, [:set_to, lambda { 
    # turn "URL 100 100" into 
    # ==> [URL, 100, 100]
    # ==> BSON won't allow URL as key because it contains '.'
    raw_data.body_images_cache.to_s.split("\n").map { |val|
      url, width, height = val.split.map(&:strip)
      [url, width.to_i, height.to_i]
    }

    # .inject({}) { |memo, val|
    #   url, width, height = val[0].strip, val[1].to_i, val[2].to_i
    #   memo[url] = {:width => width, :height => height}
    #   memo
    # }
  }]
  make :emotion, :not_empty
  make :category, :not_empty
  make :labels, :split_and_flatten, :array
  make :public_labels, :split_and_flatten, :array
  make :private_labels, :split_and_flatten, :array
  make :title, :anything
  make :teaser, :anything
  make :published_at, :datetime_or_now

  # ==== Authorizations ====
 
  def allow_as_creator? editor # NEW, CREATE
    return false unless editor
    editor.has_power_of? :MEMBER
  end

  def self.create editor, raw_data
    d = new do
      self.manipulator = editor
      self.raw_data = raw_data
      new_data.labels = []
      new_data.public_labels = []
      ask_for_or_default :lang
      ask_for :parent_message_id
      demand :owner_id, :target_ids, :body, :message_model
      ask_for :title, :category, :privacy, :labels,
          :emotion, :rating,
          :labels, :public_labels,
          :important,
          :body_images_cache
      save_create 
    end
  end

  def reader? editor # SHOW
    true
  end

  def updator? editor # EDIT, UPDATE
    owner? editor
  end

  def self.update id, editor, new_raw_data
    doc = new(id) do
      self.manipulator = editor
      self.raw_data    = new_raw_data
      ask_for :title, :body, :teaser, :public_labels, 
        :private_labels, :published_at,
        :message_model, :important,
        :body_images_cache,
        :editor_id
      save_update :record_diff => true
    end
  end

  def deletor? editor # DELETE
    true
  end

  # ==== Accessors ====

  def self.validate_params_and_find params, *args, &blok
    mess_model = params[:message_model] || params['message_model']
    invalid = case mess_model
              when String
                mess_model if not MODELS.include?(mess_model)
              when Hash
                mess_model.values.flatten.detect { |mod| !MODELS.include?(mod) }
              else
                nil
              end
    raise "Invalid message model #{invalid.inspect}" if invalid
    Member.add_docs_by_username_id(db_collection.find(params, *args, &blok).to_a)
  end

  def self.latest_by_club_id club_id, raw_params = {}, raw_opts = {}, &blok
    params = {:target_ids =>club_id, :parent_message_id => nil, :privacy => 'public' }.update(raw_params)
    opts   = {:limit=>10, :sort=>[:_id, :desc]}.update(raw_opts)
    validate_params_and_find(
      params,
      opts,
      &blok
    )
  end

  def self.latest_comments_by_club_id club_id, raw_params = {}, *args
    params = {:message_model => {:$in=>%w{jeer cheer}}}.update(raw_params)
    Message.latest_by_club_id(club_id, params, *args)
  end

  def self.latest_questions_by_club_id club_id, raw_params = {}, *args
    params = {:message_model => 'question'}.update(raw_params)
    Message.latest_by_club_id(club_id, params, *args)
  end

  def self.latest_by_parent_message_id mess_id, raw_params = {}, raw_opts = {}, &blok
    params = {:parent_message_id =>mess_id, :privacy => 'public' }.update(raw_params)
    opts   = {:limit=>10, :sort=>[:_id, :desc]}.update(raw_opts)
    validate_params_and_find(
      params,
      opts,
      &blok
    )
  end
  
  def self.latest_comments_by_parent_message_id mess_id, raw_params = {}, *args
    params = {:message_model => {:$in=>%w{jeer cheer}}}.update(raw_params)
    Message.latest_by_parent_message_id(mess_id, params, *args)
  end

  def self.latest_questions_by_parent_message_id mess_id, raw_params = {}, *args
    params = {:message_model => 'question'}.update(raw_params)
    Message.latest_by_parent_message_id(mess_id, params, *args)
  end

  def self.public raw_params = {}, raw_opts = {}, &blok
    opts = {:limit=>10, :sort=>[:_id, :desc]}.update(raw_opts)
    include_mods = [opts.delete(:include)].flatten.compact
    params = {}.update(raw_params)
    cursor = validate_params_and_find(
      params, 
      opts,
      &blok
    )
    if include_mods.empty?
      cursor
    else
      docs = cursor
      if include_mods.include?(Member)
        docs = Member.add_owner_usernames_to_collection(docs)
      end
      if include_mods.include?(Club)
        docs = Club.add_clubs_to_collection(docs)
      end
      docs
    end
  end

  def self.public_labels target_ids = nil
    map = %~
      function () {
          for (var i in this.tags) {
              emit(this.tags[i], {total:1});
          }
      };
    ~
    reduce = %~
      function (key, value) {
          var sum = 0;
          value.forEach(function (doc) {sum += doc.total;});
          return {total:sum};
      };
    ~
    opts = if target_ids
             { :query => { :target_ids=> { :$in=>target_ids}} }
           else
             { :query => { :tags => { :$ne => nil } } }
           end
    
    db_collection.map_reduce(map, reduce, opts).find().map { |doc| doc['_id'] }
  end

  def self.by_public_label label, raw_params={}, &blok
    params = { :public_labels => {:$in=>[label]} }.update(raw_params)
    validate_params_and_find( params, &blok )
  end

  def self.by_club_id_and_public_label club_id, label, raw_params = {}, raw_opts={}, &blok
    params = { 
              :target_ids    => {:$in=>[club_id]},
              :public_labels => {:$in=>[label].flatten}
              }.update(raw_params)
    opts = {:sort=>[:_id, :desc]}.update(raw_opts)
    validate_params_and_find(params, &blok)
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
      start_tm = Time.utc(start_year, start_month).strftime(time_format)
      end_tm   = Time.utc(end_year, end_month).strftime(time_format)
      params = {:published_at=>{'$gt'=>start_tm,'$lt'=>end_tm}}
      opts = {}
    end
    # time_format = '%Y-%m-%d %H:%M:%S'
    # dt = Time.now.utc
    # start_dt = dt.strftime(time_format)
    # end_dt   = (dt + (60 * 60 * 24)).strftime(time_format)
    validate_params_and_find(params, opts, &blok )
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

  def clubs
    cache['clubs.assoc'] ||= data.target_ids.map { |id|
      begin
        Club.by_id_or_member_username_id(id)
      rescue Club::Not_Found
        nil
      end
    }.compact
  end

  def club
    cache['first.club'] ||= clubs.first
  end

  def href
    "/mess/#{data._id}/"
  end

  def href_edit
    cache[:href_edit] ||= File.join(href, 'edit/')
  end

  def href_log
    cache[:href_log] ||= File.join(href, 'log/')
  end

	def message_model_in_english
		if data.message_model
			Message::MODEL_HASH[data.message_model].first 
		else
			'unkown'
		end
	end

	def message_section
		if data.message_model
			Message::MODEL_HASH[data.message_model][1]
		else
			'Unknown'
		end
	end
  
  def responds
    cache['responds'] ||= begin
                            Message.latest_by_parent_message_id(self.data._id).to_a 
                          end
  end

  def critiques
    cache['critiques'] ||= select_responds_by_model('cheer', 'jeer')
  end
  
  def suggests
    cache['suggests'] ||= select_responds_by_model('suggest')
  end
  
  def questions
    cache['questions'] ||= select_responds_by_model('question')
  end

  private 
  
  def select_responds_by_model(*mods)
    responds.select { |doc|
      mods.include?(doc['message_model'])
    }
  end


end # === end Message
