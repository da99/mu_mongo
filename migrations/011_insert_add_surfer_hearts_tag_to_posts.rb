class InsertAddSurferHeartsTagToPosts_11 < Sequel::Migration

  def up  
    rename_table :tags, :news_tags
    rename_table :taggings, :news_taggings
    
    # Insert new 'surfer_hearts' tag.
    sh_tag_id = dataset.from(:news_tags).insert :filename=> 'surfer_hearts'
    
    # Insert taggings for sh posts.
    dataset.from(:news).all.each { |post|
      dataset.from(:news_taggings).insert :model_id=>post[:id], :tag_id=>sh_tag_id
    }
  end

  def down
    rename_table :news_tags, :tags
    rename_table :news_taggings, :taggings  
    sh_tag  = dataset.from(:news_tags).where(:filename=>'surfer_hearts').first
    if sh_tag 
      dataset.from(:news_taggings).where(:tag_id=>sh_tag[:id]).delete  
    end
  end

end # === end InsertAddSurferHeartsTagToPosts
