class Club_Cage
  include The_Bunny

  def GET club_filename
    begin
      club = Club.by_id("club-#{club_filename}")
      render_html_template :Club, club_filename, {:club => club}
    rescue Club::NoRecordFound
      raise Bad_Bunny::HTTP_404, "No club with filename: #{club_filename.inspect}"
    end
  end

end # === Club_Cage
