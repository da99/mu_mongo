class Hello

	def GET_list the_stage
		the_stage.render_html_template
	end

	def GET_hi the_stage
		the_stage.render_text_html "<p>Hello ;)</p>"
	end

end
