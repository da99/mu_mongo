# ~/megauni/templates/en-us/mab/Hellos_list.rb

class Hellos_list < Base_View

  def javascripts
    default_javascripts
  end

  def title
    The_App::SITE_TAG_LINE
  end

  def meta_description
    The_App::SITE_TAG_LINE
  end

  def meta_keywords
    'lots of clubs'
  end

  def site_tag_line
    meta_description
  end
  
  def messages_public 
    @cache[:messages_public] ||= @app.env['results.messages_public'].map { |doc|
			doc['href'] = "/mess/#{doc['_id']}/"
      doc['compiled_body'] = from_surfer_hearts?(doc) ? doc['body'] : auto_link(doc['body'])
			doc
		}
  end
  
  def clubs
    @cache[:clubs] ||= @app.env['results.clubs'].map { |r| 
      r[:href] = "/clubs/#{r['filename']}/"
      r
    }
  end 
  
end # === Hello_Bunny_GET_list
