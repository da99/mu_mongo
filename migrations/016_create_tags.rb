class CreateTags < Sequel::Migration

  def up  
    create_table( :tags ) {
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
    drop_table(:tags) if table_exists?(:tags)
  end

end # === end CreateTags