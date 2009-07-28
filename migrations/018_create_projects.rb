class CreateProjects < Sequel::Migration

  def up  
    create_table( :projects ) {
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
    drop_table(:projects) if table_exists?(:projects)
  end

end # === end CreateProjects