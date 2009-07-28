class CreateMetaIds < Sequel::Migration

  def up  
    create_table( :meta_ids ) {
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
    drop_table(:meta_ids) if table_exists?(:meta_ids)
  end

end # === end CreateMetaIds