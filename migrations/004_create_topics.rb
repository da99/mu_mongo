class CreateTopics < Sequel::Migration

  def up  
    create_table( :topics ) {
      # === Associations
      primary_key :id
      
      
      # === Attributes
      smallint :parent_topic, :null=>false, :default=>0
      varchar :title, :null=>false
      
      # === Date Times
      column :created_at,  :"timestamp with time zone", :null => false
      column :modified_at, :"timestamp with time zone", :null => true
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:topics) if table_exists?(:topics)
  end

end # === end CreateTopics
