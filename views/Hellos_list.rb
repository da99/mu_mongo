# ~/megauni/templates/English/mab/Hellos_list.rb

class Hellos_list < Base_View

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
  
  def club_messages 
    [ 
      {:body=> 'mess 1', :club_name=>'BA', :href=>'/club/BA/mes34/'}, 
      {:body=> 'mess 2', :club_name=>'San Francisco', :href=>'/club/San+Francisco/mes67/'} 
    ]
  end
   
end # === Hello_Bunny_GET_list
