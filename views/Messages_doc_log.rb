# MAB   ~/megauni/templates/en-us/mab/Messages_doc_log.rb
# SASS  ~/megauni/templates/en-us/sass/Messages_doc_log.sass
# NAME  Messages_doc_log

class Messages_doc_log < Base_View

  def message
    @app.env['message_by_id']
  end
  
  def title 
    "History for: #{message.data.title || message.data._id}"
  end
  
  def logs
    @cache['message.logs'] ||= begin
                                 Doc_Log.all_by_doc_id(message.data._id, :with_assoc)
                               end
  end

end # === Messages_doc_log 
