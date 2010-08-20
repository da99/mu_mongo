
module MAB_Clubs_read_e

  def follow!
  end

  def about!
  end
  
  def post_message!
    post_message {
      css_class  'col'
      title  'Publish a new:'
      input_title 
      models  %w{e_quote e_chapter}
      hidden_input(
        :club_filename => '{{club_filename}}',
        :privacy       => 'public'
      )
    }
  end

end # === module
