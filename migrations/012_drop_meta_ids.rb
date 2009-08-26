class DropMetaIds_12 < Sequel::Migration

  def up  
    drop_table :meta_ids
  end

  def down
  end

end # === end DropMetaIds
