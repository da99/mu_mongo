class InsertMaxIdForHeartLinksImports_10 < Sequel::Migration

  def up  
    max_id = 174
    dataset.from(:meta_ids).insert :id=> max_id, :created_at=>Time.now.utc
  end

  def down
    # drop_table(:max_id_for_heart_links_imports) if table_exists?(:max_id_for_heart_links_imports)
  end

end # === end InsertMaxIdForHeartLinksImports
