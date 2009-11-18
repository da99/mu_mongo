class ToDo < Sequel::Model

  # ==== ASSOCIATIONS ==================================================
  
  belongs_to :owner
  
  belongs_to :project

  # ==== Authorizations ==============================================

  def creator? editor
    editor && (self.owner_id = editor._id)
  end
  
  def updator? editor
    creator? editor
  end
  
  # ==== CRUD ====================================================

  during :create do 
    demand :title, :details
    ask_for :days, :hours, :minutes, :seconds,
            :starts_at, :ends_at
    
  end

  during :update do
    from( :owner ) {
      ask_for :title, :details,
              :days, :hours, :minutes, :seconds,
              :starts_at, :ends_at
    }
  end

  # ==== Validators ====================================================

  validator :time do
    [:days, :hours, :minutes, :seconds, :starts_at, :ends_at].each do |col|
      set_other(col, raw_data[col].to_i )
    end    
  end


  validator :project_id do 
    must_match( doc.owner, doc.project.owner ) {
      raise "Wrong owner for project: #{doc.owner.inspect}, #{doc.project.owner}"
    }
  end

end # === end ToDo
