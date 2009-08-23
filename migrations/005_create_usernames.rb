class CreateUsernames < Sequel::Migration

  def up  
    create_table( :usernames ) {
      # === Associations
      primary_key :id
      foreign_key :owner_id, :members
      
      # === Attributes
      varchar :username, :size=>25, :unique=>true, :null=>false
      varchar :nickname, :size=>100
      varchar :email, :size=>65
      boolean :email_verified, :null=>false, :default=>false
      varchar :category, :size=>65, :default=>'Personal'
      
      # === Date Times
      column :created_at,  :"timestamp with time zone", :null => false
      column :modified_at, :"timestamp with time zone", :null => true
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:usernames) if table_exists?(:usernames)
  end

end # === end CreateUsernames
