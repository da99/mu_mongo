class CreateLoginAttempts < Sequel::Migration

  def up  
    create_table :login_attempts do
      primary_key :id
      cidr      :ip_address
      smallint  :total, :default=>0
      date      :created_at
    end
  end
  
  def down
    drop_table(:login_attempts) if table_exists?(:login_attempts)
  end
  
end # === end CreateLoginAttempts
