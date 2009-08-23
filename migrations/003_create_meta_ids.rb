class CreateMetaIds < Sequel::Migration

  def up  
    create_table( :meta_ids ) {
      # === Associations
      primary_key :id
      
      
      # === Attributes
      
      
      # === Date Times
      column :created_at,  :"timestamp with time zone", :null => false
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:meta_ids) if table_exists?(:meta_ids)
  end

end # === end CreateMetaIds
