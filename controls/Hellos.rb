# tests/Test_Control_Hellos.rb
# tests/Test_Control_Hellos_Mobile.rb
#
class Hellos
  include Base_Control

  def GET_list 
    set_header 'Cache-Control', 'public, max-age=600'
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

  def GET_rss_xml
    render_xml_template
  end
 
  def GET_google_verify
    render_text_plain "googleb9009ed100e7fc31"
  end

end # === Hello
