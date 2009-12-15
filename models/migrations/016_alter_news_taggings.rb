class AlterNewsTaggings_16 < Sequel::Migration

  def up  
    alter_table( :news_taggings ) {
      rename_column :model_id, :news_id
    }
  end

  def down
  end

end # === end AlterNewsTaggings
