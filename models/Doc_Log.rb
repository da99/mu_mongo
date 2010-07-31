require 'models/Diff_Document'

class Doc_Log

  include Couch_Plastic

  enable_timestamps
  
  make :doc_id, :mongo_object_id
  make :owner_id, :mongo_object_id, [:in_array, lambda { manipulator.username_ids } ]
  make_psuedo :old_doc, :Hash
  make_psuedo :new_doc, :Hash
  make :diff, [:set_to, lambda { 
    demand :old_doc, :new_doc
    o = raw_data.old_doc
    n = raw_data.new_doc
    o.extend Couch_Plastic::Diff_Document
    o.diff_document n
  }]

  # ==== Authorizations ====

  def self.create editor, raw_data
    new do
      self.manipulator = editor
      self.raw_data = raw_data
      demand :doc_id, :owner_id, :diff
      save_create
    end
  end

  def reader? editor 
    owner? editor
  end

  def updator? editor
    false
  end

  def deletor? editor
    false
  end

  # ==== Accessors ====

  

end # === end Doc_Log
