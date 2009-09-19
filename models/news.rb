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

  allow_viewer :STRANGER

  allow_creator :ADMIN do
    raw_data[:published_at] ||= Time.now.utc
    require_columns :title, :body
    optional_columns :teaser, :published_at, :tags
  end

  allow_updator :ADMIN do
    optional_columns :title, :body, :teaser, :published_at, :tags
  end

  validator :title do
    fn = :title
    require_string! fn
  end # === 

  validator :teaser do
    fn = :teaser
    optional_string :teaser
  end # ===

  validator :body do
    fn = :body
    require_string! fn
  end # ===

  validator :published_at do
    fn = :published_at
    self[ fn ]  = raw_data[fn] || Time.now.utc
  end

  validator :tags do
    fn = :tags
    raise "Not implemented."
  end

end # === end News
