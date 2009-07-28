class CreatePermissions < Sequel::Migration

  def up  
    create_table( :permissions ) {
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
    drop_table(:permissions) if table_exists?(:permissions)
  end

end # === end CreatePermissions