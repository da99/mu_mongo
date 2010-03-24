

class Life

  include Couch_Plastic

  # CATEGORIES = %w{ real celebrity pet baby }

  allow_fields :owner_id,
               :username,
               :audience
               # :category # real || celebrity || pet || baby || fantasy

  # ==== Hooks ====

  enable_timestamps

  def before_create
    ask_for :audience
    demand :owner_id, :username
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

  def username_validator
    must_be { 
      downcase
      not_empty
    }
    new_clean_value :_id, "life-#{username}"
  end

  def audience_validator
    must_be { 
      nil_if_empty
    }
  end

  # def category_validator
  #   must_be { in_array CATEGORIES }
  # end

end # === end Life
