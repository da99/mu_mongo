

class Message

  include Couch_Plastic

  enable_timestamps
  
  allow_fields :rating,
               :emotion,
               :question, 
               :privacy, 
               :category
               

  allow_field :owner_id do
    must_be { not_empty }
  end

  allow_field :target_ids do
    must_be { not_empty }
  end

  allow_field :body do
    must_be { not_empty }
  end


  # ==== Authorizations ====
 
  def creator? editor # NEW, CREATE
    true
  end

  def self.create editor, raw_data
    d = new(nil, editor, raw_data) do
      ask_for_or_default :lang
      demand :owner_id, :target_ids, :body
      ask :category, :privacy, :labels,
          :question, :emotion, :rating
      save_create
    end
  end

  def reader? editor # SHOW
    true
  end

  def updator? editor # EDIT, UPDATE
    true
  end

  def deletor? editor # DELETE
    true
  end

  # ==== Accessors ====



end # === end Message
