
class Club

  include Couch_Plastic

  allow_fields :filename, 
               :title, 
               :teaser, 
               :lang, 
               :created_at

  # ==== Hooks ====

  def before_create
    set_cleanest_value :lang, 'English'
    demand :title, :teaser
    ask_for :lang
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

  def news raw_params = {}
    params = {:limit=>10, :descending=>true}.update(raw_params)
    News.by_club(self.data.filename, params )
  end

  # ======== Validators ========= 
  
  def filename_validator
    must_be { not_empty }
  end

  def title_validator
    must_be { not_empty }
  end

  def teaser_validator
    accept_anything
  end

  def lang_validator
    must_be_or_raise! { 
      in_array LANGS 
    }
  end

end # === Club
