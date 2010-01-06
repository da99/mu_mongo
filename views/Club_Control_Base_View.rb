class Club_Control_Base_View < Base_View

  def club
    @app.env['the.app.club']
  end

	def club_teaser
		@app.env['the.app.club'].data.teaser
	end

	def club_filename
		@app.env['the.app.club'].data.filename
	end
	
end
