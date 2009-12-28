class Club_Control
  include Control_Base

  def GET club_filename
    begin
      club = Club.by_id("club-#{club_filename}")
      @action_name = club_filename
      env['the.app.club'] = club
      render_html_template 
    rescue Couch_Doc::No_Record_Found
      raise The_App::HTTP_404, "No club with filename: #{club_filename.inspect}"
    end
  end

end # === Club_Control
