# tests/Test_Control_Hellos.rb
# tests/Test_Control_Hellos_Mobile.rb
#
class Hellos
  include Base_Control

  def GET_list 
		env['results.messages_public'] = Message.public({}, :sort =>['created_at', :desc], :limit =>10, :include=>[Member])
		env['results.clubs']           = Club.all
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
