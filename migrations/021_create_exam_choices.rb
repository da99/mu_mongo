class CreateExamChoices < Sequel::Migration

  def up  
    create_table( :exam_choices ) {
      # === Associations
      primary_key :id
      foreign_key :exam_question_id, :exam_questions
      
      
      # === Attributes
      text :body
      boolean :correct, :null=>false, :default=>false
      
      # === Date Times
      timestamp   :created_at
      timestamp   :modified_at, :null=>true
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:exam_choices) if table_exists?(:exam_choices)
  end

end # === end CreateExamChoices
