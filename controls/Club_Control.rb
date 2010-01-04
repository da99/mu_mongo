class Club_Control
  
  include Base_Control

  def GET club_filename
    begin
      club                = Club.by_id("club-#{club_filename}")
      env['the.app.club'] = club
      @action_name        = club_filename
      render_html_template 
    rescue Couch_Doc::Not_Found
      raise The_App::HTTP_404, "No club with filename: #{club_filename.inspect}"
    end
  end

end # === Club_Control
