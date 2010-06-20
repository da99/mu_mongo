
class Club

  include Couch_Plastic

	def self.db_collection
		DB.collection('Clubs')
	end

  enable_created_at

  make :owner_id, :mongo_object_id, [:in_array, lambda { manipulator.username_ids }]

  make :filename, 
		   [:stripped, /[^a-zA-Z0-9\_\-\+]/ ], 
			 :not_empty,
       :unique

  make :title, :not_empty

  make :teaser, :not_empty
  
  # ======== Authorizations ======== 

  def creator? editor 
    return false if not new?
    return true if editor.has_power_of? :MEMBER
    # editor.has_power_of? Member::ADMIN
  end

  def self.create editor, raw_raw_data # CREATE
    new do
      
      if editor.usernames.size == 1 || !raw_raw_data['username_id']
        raw_raw_data['owner_id'] ||= editor.username_ids.first
      end
      self.manipulator = editor
      self.raw_data = raw_raw_data
      demand :owner_id, :filename, :title, :teaser
      ask_for_or_default :lang
      save_create 
    end
  end

  def reader? editor
    true
  end

  def updator? editor
    if editor.has_power_of?(:ADMIN) ||
       editor.has_power_of?(data.owner_id)
      return true
    end
    false
  end

  def self.update id, editor, new_raw_data # UPDATE
    doc = new(id) do
      self.manipulator = editor
      self.raw_data = new_raw_data
      ask_for :title, :teaser
      save_update 
    end
  end
  
  def deletor? editor
    creator? editor
  end

  # ======== Accessors ======== 

  def self.db_collection_followers
    DB.collection('Club_Followers')
  end

  def self.by_id id
    begin
      super(id)
    rescue Club::Not_Found
      orig = $!
      begin
        doc = Member.username_doc_by_id(id)
        doc['filename']  = doc['username']
        doc['title']     = "#{doc['username']}'s Fan Club"
        club = Club.new doc
        def club.life_club?
          true
        end
        club
      rescue Member::Not_Found
        raise orig
      end
    end
  end
  
  def self.all raw_params = {}, &blok
    db_collection.find( raw_params, &blok)
  end

  def self.all_ids params = {}, opts = {}
    db_collection.find( params, {:fields=>['_id']}.update(opts) ).map { |doc|
      doc['_id']
    }
  end
  
  def self.all_ids_for_owner( raw_id )
    id = Couch_Plastic.mongofy_id( raw_id )
    db_collection.find({:owner_id=>id}, {:fields=>'_id'}).map { |doc|
      doc['_id']
    }
  end

  def self.all_ids_for_follower( raw_id )
    id = Couch_Plastic.mongofy_id( raw_id )
    db_collection_followers.find({:follower_id=>id}, {:fields=>'club_id'}).map { |doc|
      doc['club_id']
    }
  end

  def self.all_ids_for_follower_id( raw_id )
    id = Couch_Plastic.mongofy_id( raw_id )
    db_collection_followers.find({:follower_id=>id}, {:fields=>'club_id'}).map { |doc|
      doc['club_id']
    }
  end

  def self.all_filenames 
    db_collection.find().map {|r| r['filename']}
  end

  def self.add_clubs_to_collection raw_coll
    coll     = (raw_coll.is_a?(Array)) ? raw_coll : raw_coll.to_a
    club_ids = coll.map { |doc| doc['target_ids'] }.compact.flatten.uniq
    clubs    = Club.db_collection.find({ :_id=>{:$in=>club_ids}}).inject({}) { | m, club| 
      m[club['_id']] = club
      m
    } 
    
    coll.map { |doc|
      target = clubs[doc['target_ids'].first]
      doc['club_title'], doc['club_filename'] = if target
                                                  [target['title'], target['filename']]
                                                end

      doc
    }
  end

  def self.by_club_model raw_models, opts = {}
    models = [raw_models].flatten.compact.uniq
    clubs = db_collection.find({:club_model=>{:$in=>models}}, opts)
  end
  
  def self.by_filename filename
    club = db_collection.find_one('filename'=>filename)
    if not club
      raise Couch_Plastic::Not_Found, "Club by filename: #{filename.inspect}"
    end
    Club.new(club)
  end

  def self.by_owner_ids raw_ids, raw_opts={}
    username_ids = [raw_ids].flatten.compact
    return [] if username_ids.empty?
    db_collection.find(
      {:owner_id=>{:$in=>username_ids}}, 
      raw_opts
    )
  end

  def owner?(mem)
    return false if not mem
    mem.username_ids.include?(data.owner_id)
  end

  def life_club?
    false
  end

  def href 
    cache[:href] ||= begin
                       if life_club?
                         "/life/#{data.filename}/"
                       else
                         "/clubs/#{data.filename}/"
                       end
                     end
  end

  def follow_href
    cache[:follow_href] ||= "/clubs/#{data.filename}/follow/"
  end

  def followers
    cache[:followers] ||= self.class.db_collection_followers.find(:club_id=>data._id).map { |doc|
      doc['follower_id']
    }
  end

  def potential_follower? mem
    return false if !mem || owner?(mem) || follower?(mem)
    true
  end

  def follower? mem
    return false if not mem
    return false if owner?(mem)
    mem.username_ids.detect { |un| 
      followers.include?(un)
    }
  end

  # === Other Instance Methods

  def create_follower mem, username_id
    self.class.db_collection_followers.insert(
      '_id' => "#{data._id}#{mem.data._id}",
      'club_id' => data._id, 
      'follower_id' => Couch_Plastic.mongofy_id(username_id)
    )
  end

end # === Club
