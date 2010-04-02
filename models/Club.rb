
class Club

  include Couch_Plastic

  enable_created_at

  allow_field(:owner_id) {
    must_be {
      not_empty
    }
  }

  allow_field(:username_id) {
    must_be {
      in_array(doc.manipulator.usernames.map {|u| "username-#{u}"} )
    }
  }

  allow_field(:filename) {
    must_be { 
      stripped( /[^a-zA-Z0-9\_\-\+]/ )
      not_empty 
    }
    new_clean_value :_id, "club-#{cleanest(:filename)}"
  }

  allow_field(:title) {
    must_be { not_empty }
  }

  allow_field(:teaser) {
    must_be { not_empty }
  }
  
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
        if err.is_a? Couch_Doc::HTTP_Error_409_Update_Conflict
          errors << "Filename already taken: #{cleanest(:filename)}"
        end    
      }
    end
  end

  def reader? editor
    true
  end

  def updator? editor
    creator? editor
  end

  def self.update id, editor, new_raw_data # UPDATE
    doc = new(id, editor, new_raw_data)
    doc.ask_for :title
    doc.save_update 
    doc
  end
  
  def deletor? editor
    creator? editor
  end

  # ======== Accessors ======== 

  def self.all raw_params = {}
    params = {:include_docs=>true}.update(raw_params)
    raw = CouchDB_CONN.GET_by_view :clubs, params
    raw.map { |r| r[:doc] }
  end

  def self.all_filenames 
    CouchDB_CONN.GET_by_view(:clubs).map { |r| r[:key] }
  end

  def news raw_params = {}
    params = {:limit=>10, :descending=>true}.update(raw_params)
    News.by_club(self.data.filename, params )
  end

  def href 
    @assoc_cache[:href] = "/clubs/#{data._id.gsub('club-', '')}/"
  end

end # === Club
