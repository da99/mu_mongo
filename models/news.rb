class News 

  include CouchPlastic

  # ==== CONSTANTS =====================================================
  
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  # one_to_many :taggings, :class_name=>'NewsTagging', :key=>:news_id
  # one_to_many :tags, :class_name=>'NewsTag', :dataset=> proc { 
  #   NewsTag.filter(:id=>taggings_dataset.select(:id))
  # }

  # ==== HOOKS =========================================================


  # ==== CLASS METHODS =================================================


  # ==== INSTANCE METHODS ==============================================

  def last_modified_at
    updated_at || created_at
  end

  def self.show editor, raw_data
    :STRANGER
  end

  def self.create editor, raw_data
    valid_editor_or_raise editor, :ADMIN
    raw_data[:published_at] ||= Time.now.utc
    require_columns :title, :body
    optional_columns :teaser, :published_at, :tags
  end

  def self.update editor, raw_data
    valid_editor_or_raise editor, :ADMIN 
    optional_columns :title, :body, :teaser, :published_at, :tags
  end

  def title= raw_data
    fn = :title
    require_string! fn
  end # === 

  def teaser= raw_data
    fn = :teaser
    optional_string :teaser
  end # ===

  def body= raw_data
    fn = :body
    require_string! fn
  end # ===

  def published_at= raw_data
    fn = :published_at
    self[ fn ]  = raw_data[fn] || Time.now.utc
  end

  def tags= raw_data
    fn = :tags
    raise "Not implemented."
  end

end # === end News
