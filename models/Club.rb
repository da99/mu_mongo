
class Club

  include Couch_Plastic

  allow_fields :filename, 
               :title, 
               :teaser, 
               :lang, 
               :created_at

  # ==== Hooks ====

  def before_create
    new_clean_value :lang, 'English'
    demand :filename, :title, :teaser
    ask_for :lang
  end

  def on_error_save_create excep
    case excep
    when Couch_Doc::HTTP_Error_409_Update_Conflict
      errors << "Filename already taken: #{cleanest(:filename)}"
    else
      raise excep
    end
  end

  def before_update
    ask_for :title
  end

  # ======== Authorizations ======== 

  def creator? editor 
    editor.has_power_of? Member::ADMIN
  end
  alias_method :updator?, :creator?
  alias_method :deletor?, :creator?

  def reader? editor
    true
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

  # ======== Validators ========= 
  
  def filename_validator
    must_be { not_empty }
    new_clean_value :_id, "club-#{cleanest(:filename)}"
  end

  def title_validator
    must_be { not_empty }
  end

  def teaser_validator
    must_be { not_empty }
  end

  def lang_validator
    must_be! { 
      in_array LANGS 
    }
  end

end # === Club
