
module BASE_MAB_Clubs

  def list_name
    self.class.to_s.split('Clubs_').last
  end

  def messages! &blok
    div.col.messsages! &blok
  end

  def loop_messages!
    loop_messages list_name
  end
  
  def publisher_guide! &blok
    if_empty list_name do
      div.section.publisher_guide! do
        owner {
          publisher_guide
        }
        insider {
          publisher_guide
        }
      end
    end
  end

  def guide txt, &blok
    div.section.guide {
      h3 txt
      blok.call
    }
  end
  
  def follow!
    a_button 'Follow', 'href_follow'
  end
  alias_method :omni_follow!, :follow!

  def about header, body
    div.section.about {
      h3 header.m!
      div.body body.m!
    }
  end
  
  def about! &blok
    div.col.about! &blok
  end

end # === module
