
module MAB_Clubs_read_fights

  def post_message!
    post_message {
      css_class  'col'
      title      'Publish a new:'
      models     %w{fight complaint debate}
      input_title 
      hidden_input(
        :club_filename => '{{club_filename}}',
        :privacy       => 'public'
      )
    }
  end

end # === module
