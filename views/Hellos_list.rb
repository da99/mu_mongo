# ~/megauni/templates/en-us/mab/Hellos_list.rb
# ~/megauni/controls/Hellos.rb

class Hellos_list < Base_View
  
  def javascripts
    default_javascripts
  end

  def title
    "#{The_App::SITE_TITLE}"
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
    @cache[:clubs] ||= begin
                         old_clubs + @app.env['results.clubs'].map { |r| 
                           r[:href] = "/clubs/#{r['filename']}/"
                           r
                         }  
                       end
  end 

  def city_clubs
    @cache['cities'] ||= compile_clubs(Club.by_club_model('city'))
  end

  def beauty_clubs
    @cache['beauty'] ||= compile_clubs(Club.by_club_model(['healty', 'beauty']))
  end

  def political_clubs
    @cache['evil'] ||= compile_clubs(Club.by_club_model(['economics', 'history']))
  end

  def joy_clubs
    @cache['joy'] ||= compile_clubs(Club.by_club_model(['joy', 'fun']))
  end

  %w{ city joy }.each { |club|
    eval(%~
      def #{club}_clubs?     
       @cache['not_empty_#{club}'] ||= begin
         arr = #{club}_clubs
         arr && !arr.empty?
       end
      end
    ~)
  }

  def political_beauty?
    @cache['not_empty_pb'] ||= begin
                                 !(beauty_clubs.empty? && political_clubs.empty?)
                               end
  end
  
end # === Hello_Bunny_GET_list
