class CreateExamQuestions < Sequel::Migration

  def up  
    create_table( :exam_questions ) {
      # === Associations
      primary_key :id
      foreign_key :exam_id, :exams
      
      # === Attributes
      text :body
      text :details
      smallint :category, :null=>false, :default=>0
      
      # === Date Times
      timestamp   :created_at
      timestamp   :modified_at, :null=>true
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:exam_questions) if table_exists?(:exam_questions)
  end

end # === end CreateExamQuestions
