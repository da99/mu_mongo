
class Club

  include Couch_Plastic

	def self.db_collection
		DB.collection('Clubs')
	end

  enable_created_at

  make :owner_id, :not_empty

  make :username_id, [:in_array, lambda { doc.manipulator.username_ids }]

  make :filename, 
		   [:stripped, /[^a-zA-Z0-9\_\-\+]/ ], 
			 :not_empty

  make :title, :not_empty

  make :teaser, :not_empty
  
  # ======== Authorizations ======== 

  def creator? editor 
    return true if editor.has_power_of? :MEMBER
    # editor.has_power_of? Member::ADMIN
  end

  def self.create editor, raw_raw_data # CREATE
    new(nil, editor, raw_raw_data) do
      raw_raw_data[:owner_id] = editor.data._id
      if editor.usernames.size == 1 || !raw_raw_data[:username_id]
        raw_raw_data[:username_id] ||= 'username-' + editor.usernames.first
      end
      demand :owner_id, :username_id, :filename, :title, :teaser
      ask_for_or_default :lang
      save_create { |err| 
        if err.is_a? Couch_Plastic::HTTP_Error_409_Update_Conflict
          errors << "Filename already taken: #{cleanest(:filename)}"
        end    
      }
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
    doc = new(id, editor, new_raw_data) do
      ask_for :title, :teaser
      save_update 
    end
  end
  
  def deletor? editor
    creator? editor
  end

  # ======== Accessors ======== 

  def self.all raw_params = {}, &blok
    db_collection.find( raw_params, &blok)
  end

  def self.all_filenames 
    db_collection.find().map {|r| r['filename']}
  end

  def href 
    cache[:href] = "/clubs/#{data.filename}/"
  end

end # === Club
