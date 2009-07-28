class CreateExams < Sequel::Migration

  def up  
    create_table( :exams ) {
      # === Associations
      primary_key :id
      smallint :project_id, :null=>false, :default=>0
      
      # === Attributes
      varchar :title
      text :body
      
      # === Date Times
      timestamp   :created_at
      timestamp   :modified_at, :null=>true
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:exams) if table_exists?(:exams)
  end

end # === end CreateExams
