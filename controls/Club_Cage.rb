class Club_Cage
  include Control_Base

  def GET club_filename
    begin
      club = Club.by_id("club-#{club_filename}")
      self.action_name = club_filename
      render_html_template :club => club
    rescue Couch_Doc::No_Record_Found
      raise Bad_Bunny::HTTP_404, "No club with filename: #{club_filename.inspect}"
    end
  end

end # === Club_Cage
