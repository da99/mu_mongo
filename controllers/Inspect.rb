class Inspect

  def GET_list the_stage
    file_contents = File.read(File.expand_path(__FILE__)).split("\n")
    end_index     = file_contents.index('__' + 'END' + '__')
    
    the_stage.render_html_template self
  end
  
	def GET_request the_stage
		if the_stage.class.development?
			the_stage.render_text_html "<pre>" + the_stage.request.env.keys.sort.map { |key| 
				key.inspect + (' ' * (30 - key.inspect.size).abs) + ': ' + the_stage.request.env[key].inspect 
			}.join("<br />") + "</pre>"
		else
			raise Bad_Bunny::HTTP_404, "/request only allowed in :development environments."
		end
	end
	
end # === Request_Bunny
