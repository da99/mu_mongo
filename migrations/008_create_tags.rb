class CreateTags_8 < Sequel::Migration

  def up  
    create_table( :tags ) {
      # === Associations
      primary_key :id
      
      
      # === Attributes
      varchar :filename, :size=>30, :unique=>true
      
      # === Date Times
      # None so far.
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:tags) if table_exists?(:tags)
  end

end # === end CreateTags
