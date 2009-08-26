class CreateTags_8 < Sequel::Migration

  def up  
    create_table( :news_tags ) {
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
    drop_table(:news_tags) if table_exists?(:news_tags)
  end

end # === end CreateTags
