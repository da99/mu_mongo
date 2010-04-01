# ~/megauni/templates/English/mab/Hellos_list.rb

class Hellos_list < Base_View

  def javascripts
    default_javascripts
  end

  def title
    'Coming Soon...'
  end

  def meta_description
    The_App::Options::SITE_TAG_LINE
  end

  def meta_keywords
    The_App::Options::SITE_KEYWORDS
  end

  def site_tag_line
    meta_description
  end
  
  def messages_public 
    @cache[:messages_public] ||= @app.env['results.messages_public'].map { |raw|
			doc = raw[:doc]
			doc[:href] = "/mess/#{Message.strip_class_name(doc[:_id])}/"
      doc[:compiled_body] = auto_link(doc[:body])
			doc
		}
  end
  
  def clubs
    @cache[:clubs] ||= @app.env['results.clubs'].map { |r| 
      r[:href] = "/clubs/#{r[:filename]}/"
      r
    }
  end 
  
end # === Hello_Bunny_GET_list
