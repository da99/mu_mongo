module TimestampIt

  def self.included(target)
    target.before_create {
      self.created_at = Time.now.utc if self.columns.include?(:created_at)
    }
    target.before_update {
      self.modified_at = Time.now.utc  if self.class.columns.include?(:modified_at)
    }
  end
  
end # === TimestampIt
