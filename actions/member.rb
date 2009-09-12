
# ============= Member Actions ==========================          

get( "/sign\-up/" ) do
  require_ssl!
  describe :member, :new
  render_mab
end

          
post( "/member/" ) do
  log_out! 
  
  begin

    m = Member.creator( current_member, clean_room )
    self.current_member = m
    flash.success_msg = "Your account has been created."
    redirect('/account/')
    
  rescue Sequel::ValidationFailed

    flash.error_msg = to_html_list( $!.message )
    session[ :form_username  ] = clean_room[:username] 
             
    redirect('/sign-up/')
  end
    
end # == post :create


# =========================== MEMBER ONLY ==========================================

# Show account and HTML pages on same view.
get( "/account/" ) do
  require_log_in!
  describe :account, :show
  render_mab
end # == get :show

      
put( "/member/" )  do
  begin
    m = Member.updator( current_member, clean_room )
    flash.success_msg = "Data has been updated and saved."
    redirect('/account/')
  rescue Sequel::ValidationFailed
    flash.error_msg = to_html_list($!.message)
    redirect('/account/')
  end
end # === put :update






