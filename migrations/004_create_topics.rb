class CreateTopics < Sequel::Migration

  def up  
    create_table( :topics ) {
      # === Associations
      primary_key :id
      
      
      # === Attributes
      smallint :parent_topic, :null=>false, :default=>0
      varchar :title, :null=>false
      
      # === Date Times
      timestamp   :created_at
      timestamp   :modified_at, :null=>true
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:topics) if table_exists?(:topics)
  end

end # === end CreateTopics
