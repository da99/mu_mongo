helpers {

  def render_success_msg(msg)
    controller :main
    action :success_msg
    @success_msg = msg
    @partial ||= template_name
    
    halt( 200, 'Data was saved.') # render_mab )
  end

  
  def render_error_msg( http_error_code, msg)
    controller :main
    action :error_msg
    @error_msg = msg
    halt( http_error_code || 200, 'Error occurred. Go back to previous page.') # render_mab)
  end

} # === helpers
