class AlterLoginsToLogIns_18 < Sequel::Migration

  def up  
    rename_table :login_attempts, :log_in_attempts )   end

  def down
    drop_table(:log_in_attempts) if table_exists?(:log_in_attempts)
  end

end # === end AlterLoginsToLogIns
