class CreateUsernames < Sequel::Migration

  def up  
    create_table( :usernames ) {
      # === Associations
      primary_key :id
      
      
      # === Attributes
      varchar :username, :size=>25, :unique=>true, :null=>false
      
      # === Date Times
      timestamp   :created_at
      timestamp   :modified_at, :null=>true
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:usernames) if table_exists?(:usernames)
  end

end # === end CreateUsernames