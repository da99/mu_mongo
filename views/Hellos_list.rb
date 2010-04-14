# ~/megauni/templates/en-us/mab/Hellos_list.rb

class Hellos_list < Base_View

  def javascripts
    default_javascripts
  end

  def title
    "#{The_App::SITE_TITLE} #{The_App::SITE_TAG_LINE}"
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
                         old_clubs = [ 
                           { :teaser=>nil, :href=>'/salud/',    :title=>'Salud (Español)'},
                           { :teaser=>nil, :href=>'back_pain',  :title=>'Back Pain'},
                           { :teaser=>nil, :href=>'child_care', :title=>'Child Care'},
                           { :teaser=>nil, :href=>'computer',   :title=>'Computer Use'},
                           { :teaser=>nil, :href=>'hair',      :title=>'Skin & Hair'},
                           { :teaser=>nil, :href=>'housing',   :title=>'Housing & Apartments'},
                           { :teaser=>nil, :href=>'health',    :title=>'Pain & Disease'},
                           { :teaser=>nil, :href=>'preggers',  :title=>'Pregnancy'}
                         ]

                         old_clubs + @app.env['results.clubs'].map { |r| 
                           r[:href] = "/clubs/#{r['filename']}/"
                           r
                         }  
                       end
  end 
  
end # === Hello_Bunny_GET_list
