          
get( "/sign\-up/" ) do
  require_ssl!
  describe :member, :new
  render_mab
end

          
post( "/member/" ) do
  
  session.clear 
  
  begin

    m = Member.editor_create( current_member, clean_room )
    
    flash[ :success_msg ] = "Your account has been created."
    session[:member_username] = m.username
    redirect('/account/')
    
  rescue Sequel::ValidationFailed

    flash[ :error_msg ] = to_html_list( $!.message )
    flash[ :username  ] = clean_room['username'] 
             
    redirect('/sign-up/', 307) # temporary redirect
  end
    
end # == post :create


# =========================== MEMBER ONLY ==========================================

# Show account and HTML pages on same view.
get( "/admin/" ) do
  protected_for( :MEMBER, :member, :show ) {
    @slice_locations = []
    render_mab
  }
end # == get :show

      
put( "/member/" )  do
  begin
    m = Member.editor_update( current_member, clean_room )
    flash[:success_msg] = "Data has been updated and saved."
    redirect('/account/')
  rescue Sequel::ValidationFailed
    flash[:error_msg] = to_html_list(m.errors.full_messages)
    redirect('/account/')
  end
end # === put :update






