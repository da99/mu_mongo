
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
    if_empty list_name, &blok
  end

  def guide! txt, &blok
    div.section.guide {
      h3 txt
      blok.call
    }
  end
  
  def follow!
    a_button 'Follow', 'href_follow'
  end
  
  attr_reader :perm_level
  %w{ stranger member insider owner }.each { |level|
    eval %~
      def #{level} &blok
        @perm_level = :#{level}
        
        gath = Gather.new(&blok)
        show_if '#{level}?' do
          gath.meths.each { |meth|
            send("#{level}_\#{meth.first}", *(meth[1]), &(meth.last))
          }
        end
        
        @perm_level = nil
      end
    ~
  }
  
  def member_or_insider &blok
    member &blok
    insider &blok
  end

  def insider_or_owner &blok
    insider &blok
    owner &blok
  end

  # ======== CONTENT METHODS ===================

  def about! header, body
    div.section.about {
      h3 header.m!
      div.body body.m!
    }
  end
end # === module
