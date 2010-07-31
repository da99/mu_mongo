
require 'differ'

module Couch_Plastic::Differ_To_Document
  def to_document
    raw_array.map { |change|
      case change
      when String
        change
      when Differ::Change
        [change.delete, change.insert] 
      else
        raise ArgumentError, "Unknown class: #{change.class}"
      end
    }
  end
end # === module 

module Couch_Plastic::Diff_Document

  def diff_document new_doc
    raise "Invalid type: #{self.class}" unless self.is_a?(Hash)
    differ = Differ.diff_by_word(new_doc, self)
    differ.extend Differ_To_Document
    differ.to_document
  end
  
end # === module
