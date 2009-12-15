class CreateNews_7 < Sequel::Migration

  def up  
    create_table( :news ) {
      # === Associations
      primary_key :id
      
      
      # === Attributes
      varchar :title, :null=>false
      text :teaser
      text :body, :null=>false
      
      
      # === Date Times
      timestamp   :created_at, :null=>false
      timestamp   :updated_at, :null=>true
      timestamp   :published_at, :null=>false
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:news) if table_exists?(:news)
  end

end # === end CreateNews
