class CreateTaggings < Sequel::Migration

  def up  
    create_table( :taggings ) {
      # === Associations
      primary_key :id
      
      
      # === Attributes
      
      
      # === Date Times
      timestamp   :created_at
      timestamp   :modified_at, :null=>true
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:taggings) if table_exists?(:taggings)
  end

end # === end CreateTaggings