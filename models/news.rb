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

  def textile?
    last_modified_at < Time.utc(2009, 9, 17)
  end

  def attr_html(col)
    textile? ? RedCloth.new(self[col]).to_html : self[col]
  end

  def teaser_html
    attr_html :teaser
  end

  def body_html
    attr_html :body
  end

  allow_viewer :STRANGER

  allow_creator :ADMIN do
    require_columns :title, :body
    optional_columns :teaser, :published_at, :tags
  end

  allow_updator :ADMIN do
    optional_columns :title, :body, :teaser, :published_at, :tags
  end


end # === end News
