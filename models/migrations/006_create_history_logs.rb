class CreateHistoryLogs < Sequel::Migration

  def up  
    create_table( :history_logs ) {
      # === Associations
      primary_key :id
      foreign_key :owner_id, :members
      foreign_key :editor_id, :members
      
      # === Attributes
      
      varchar     :action, :size=>25, :null=>false
      text        :body, :null=>false
      
      # === Date Times
      column :created_at,  :"timestamp with time zone", :null => false
      
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:history_logs) if table_exists?(:history_logs)
  end

end # === end CreateHistoryLogs
