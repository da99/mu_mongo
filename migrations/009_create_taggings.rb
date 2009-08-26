class CreateTaggings_9 < Sequel::Migration

  def up  
    create_table( :taggings ) {
      # === Associations
      primary_key :id
      
      
      # === Attributes
      smallint :model_id, :null=>false, :default=>0
      smallint :tag_id, :null=>false, :default=>0
      
      # === Date Times
      # None so far. 
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:taggings) if table_exists?(:taggings)
  end

end # === end CreateTaggings
