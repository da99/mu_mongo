class Club_Cage
  include Control_Base

  def GET club_filename
    begin
      club = Club.by_id("club-#{club_filename}")
      self.action_name = club_filename
      env['bunny.club'] = club
      render_html_template 
    rescue Couch_Doc::No_Record_Found
      raise Bad_Bunny::HTTP_404, "No club with filename: #{club_filename.inspect}"
    end
  end

end # === Club_Cage
