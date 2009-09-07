class CreateProjects_15 < Sequel::Migration

  def up  
    create_table( :projects ) {
      # === Associations
      primary_key :id
      
      
      # === Attributes
      varchar :title, :null=>false
      
      # === Date Times
      # None so far.
      #
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:projects) if table_exists?(:projects)
  end

end # === end CreateProjects
