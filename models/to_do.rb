class ToDo < Sequel::Model

  # ==== CONSTANTS =====================================================
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  many_to_one :owner, :class_name=>'Member', :key=>:owner_id
  many_to_one :project
  
  # ==== HOOKS =========================================================


  # ==== CLASS METHODS =================================================


  # ==== INSTANCE METHODS ==============================================

  allow_creator :MEMBER do 
    require_columns :title, :details
    optional_columns :days, :hours, :minutes, :seconds,
                     :starts_at, :ends_at
    self[:owner_id] = self.current_editor[:id]
  end

  allow_updator :owner do
    optional_columns :title, :details,
                     :days, :hours, :minutes, :seconds,
                     :starts_at, :ends_at
  end

  [:days, :hours, :minutes, :seconds].each do |col|
    validator col do 
      self[col] = self.raw_data[col].to_i
    end
  end

  [:starts_at, :ends_at].each do |col|
    validator col do
      self[col] = self.raw_data[col].to_i
    end
  end

  validator :project_id do
    require_same_owner :project 
  end

end # === end ToDo
