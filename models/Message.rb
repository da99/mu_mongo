

class Message

  include Couch_Plastic

  allow_fields :owner_id,
               :target_ids,
               :body,
               :rating,
               :emotion,
               :question, 
               :labels,
               :privacy, 
               :category,
               :lang

  # ==== Hooks ====

  enable_timestamps

  def before_create
    new_clean_value :lang, 'en-us'
    demand :owner_id, :target_ids, :body
    ask :lang, :category, :privacy, :labels,
        :question, :emotion, :rating
  end


  # ==== Authorizations ====
 
  def creator? editor # NEW, CREATE
  end

  def reader? editor # SHOW
  end

  def updator? editor # EDIT, UPDATE
  end

  def deletor? editor # DELETE
  end

  # ==== Accessors ====

  

  # ==== Validators ====

  def owner_id_validator
    must_be { not_empty }
  end

  def club_id_validator
    must_be { not_empty }
  end

  def target_ids
    must_be { not_empty }
  end

  def body
    must_be { not_empty }
  end

end # === end Message
