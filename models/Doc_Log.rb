require 'models/Diff_Document'

class Doc_Log

  include Couch_Plastic

  enable_timestamps
  
  make :doc_id, :mongo_object_id
  make :editor_id, :mongo_object_id, [:in_array, lambda { manipulator.username_ids } ]
  make_psuedo :old_doc, :Hash
  make_psuedo :new_doc, :Hash
  make :diff, [:set_to, lambda { 
    demand :old_doc, :new_doc
    o = raw_data.old_doc
    n = raw_data.new_doc
    o.extend Couch_Plastic::Diff_Document
    o.diff_document n
  }]

  # ==== Getters ====
  
  def self.by_doc_id id
    doc = db_collection.find_one( :doc_id=>Couch_Plastic.mongofy_id(id) )
    raise Doc_Log::Not_Found, "Doc log by document id: #{id.inspect}" unless doc
    new(doc)
  end

  def self.all_by_doc_id id, *opts
    valid_opts = [:with_assoc]
    invalid_opts = opts - valid_opts
    raise "Invalid options: #{invalid_opts.inspect}" unless invalid_opts.empty?

    docs = db_collection.find(:doc_id=>Couch_Plastic.mongofy_id(id)).to_a
    
    if opts.include?(:with_assoc)
      Member.add_docs_by_username_id(docs, 'editor_id')
    end
    
    docs
  end

  # ==== Authorizations ====

  def allow_as_creator? editor = nil
    true
  end

  def self.create editor, raw_data
    new do
      self.manipulator = editor
      self.raw_data = raw_data
      demand :doc_id, :editor_id, :diff
      save_create
    end
  end

  def reader? editor 
    editor.is_a?(Member) && editor.admin?
  end

  def updator? editor
    false
  end

  def deletor? editor
    false
  end

  # ==== Accessors ====

  

end # === end Doc_Log
