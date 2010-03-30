
class Club

  include Couch_Plastic

  enable_created_at

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
      demand :filename, :title, :teaser
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

  def self.all params = {}
    raw = CouchDB_CONN.GET_by_view :clubs, params
    results = raw[:rows].map { |row|
      row.delete :key
      row.update row.delete(:value)
    }
  end

  def news raw_params = {}
    params = {:limit=>10, :descending=>true}.update(raw_params)
    News.by_club(self.data.filename, params )
  end

end # === Club
