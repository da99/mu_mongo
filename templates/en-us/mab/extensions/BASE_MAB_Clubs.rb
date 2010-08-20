
module BASE_MAB_Clubs

  def list_name
    self.class.to_s.split('Clubs_').last
  end

  def loop_messages!
    loop_messages list_name
  end
  
  def publisher_guide! &blok
    if_empty list_name, &blok
  end
  
  def follow!
    a_button 'Follow', 'href'
  end
  
  %w{ stranger member insider owner }.each { |level|
    eval %~
      def #{level} &blok
        show_if '#{level}?', &blok
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

end # === module
