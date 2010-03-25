

class Message

  include Couch_Plastic

  enable_timestamps
  
  allow_fields :rating,
               :privacy

  allow_field :owner_id do
    must_be { not_empty }
  end

  allow_field :target_ids do
    must_be { 
      not_empty 
      array
    }
  end

  allow_field :body do
    must_be { not_empty }
  end

  allow_field :emotion do 
    must_be { not_empty }
  end

  allow_field :category do
    must_be { not_empty }
  end

  allow_field :labels do
    must_be { array }
  end

  allow_field :public_labels do
    must_be { array }
  end



  # ==== Authorizations ====
 
  def creator? editor # NEW, CREATE
    true
  end

  def self.create editor, raw_data
    d = new(nil, editor, raw_data) do
      ask_for_or_default :lang
      demand :owner_id, :target_ids, :body
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
    true
  end

  def deletor? editor # DELETE
    true
  end

  # ==== Accessors ====



end # === end Message
