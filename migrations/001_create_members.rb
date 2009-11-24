class CreateMembers < Sequel::Migration

  def up
    create_table( :members ) {
    
      # === Attributes
      primary_key :id


      varchar     :hashed_password,  :size=>255
      varchar     :salt,             :size=>255
      smallint    :security_level, :null=>false, :default=>1

      # smallint :karma_good_total, :null=>false, :default=>0
      # smallint :karma_bad_total, :null=>false, :default=>0
      # smallint :spam_total, :null=>false, :default=>0
      # smallint :scam_total, :null=>false, :default=>0
      # boolean :verified, :null=>false, :default=>false

      # === Date Times
      column :created_at,  :"timestamp with time zone", :null => false

      # ==== Aggregates
      # None.
    }          
  end

  def down
    drop_table :members  if table_exists?(:members)
  end

end # ---------- end CreateMembers



