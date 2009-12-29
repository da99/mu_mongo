class Hello
  include Base_Control

	def GET_list 
		render_html_template
	end

  def GET_salud
    render_html_template
  end

  def GET_help
    render_html_template
  end

  def GET_sitemap_xml
    render_xml_template
  end


end # === Hello
