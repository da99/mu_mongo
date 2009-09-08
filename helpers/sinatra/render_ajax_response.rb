helpers {

  def render_success_msg(msg)
    describe :main, :success_msg
    delete_form_draft_cookie
    @success_msg = msg
    @partial ||= template_name
    
    halt( 200, render_mab )
  end

  
  def render_error_msg( http_error_code, msg)
      describe :main, :error_msg
      @error_msg = msg
      halt( http_error_code || 200, render_mab)
  end

} # === helpers
