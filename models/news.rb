class News < Sequel::Model

  # ==== CONSTANTS =====================================================
  
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  one_to_many :taggings, :class_name=>'NewsTagging', :key=>:news_id
  
  # ==== HOOKS =========================================================


  # ==== CLASS METHODS =================================================


  # ==== INSTANCE METHODS ==============================================

  def last_modified_at
    updated_at || created_at
  end

  allow_creator :ADMIN do
    require_columns :title, :body
    optional_columns :teaser, :published_at, :tags
  end

  allow_updator :ADMIN do
    optional_columns :title, :body, :teaser, :published_at, :tags
  end


end # === end News
