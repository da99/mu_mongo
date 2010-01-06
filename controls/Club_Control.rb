require 'views/Club_Control_Base_View'

class Club_Control
  
  include Base_Control

  def GET club_filename
		save_club_to_env(club_filename)
		@action_name = club_filename
		render_html_template 
  end

	def GET_edit club_filename
		require_log_in! :ADMIN
		save_club_to_env(club_filename)
		render_html_template
	end

	private # ======================================

	def save_club_to_env id
		club_filename       = "club-#{id.sub('club-', '')}"
		env['the.app.club'] = Club.by_id club_filename
	rescue Couch_Doc::Not_Found
		raise The_App::HTTP_404, "No club with filename: #{club_filename.inspect}"
	end

end # === Club_Control
