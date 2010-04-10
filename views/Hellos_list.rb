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
    @cache[:messages_public] ||= compile_messages(@app.env['results.messages_public'])
  end
  
  def clubs
    @cache[:clubs] ||= @app.env['results.clubs'].map { |r| 
      r[:href] = "/clubs/#{r['filename']}/"
      r
    }
  end 
  
end # === Hello_Bunny_GET_list
