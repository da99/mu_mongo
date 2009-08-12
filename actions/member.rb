# ============================= STRANGERS =========================================
          
get( "/sign\-?up" ) do
  require_ssl!
  describe :member, :new
  render_mab
end

          
post( "/member" ) do
  
  session.clear 
  
  begin
    m = Member.create_it( clean_room, nil )
    m.save  
                      
    flash( :success_msg,  "Your account has been created." )
    session[:member_username] = m.username
    redirect('/account')
    
  rescue Sequel::ValidationFailed

    flash( :error_msg, m.error_msg )
    flash( :username,  clean_room['username'] )
             
    redirect('/sign-up', 307) # temporary redirect
  end
    
end # == post :create


# =========================== MEMBER ONLY ==========================================

# Show account and HTML pages on same view.
get( "/admin" ) do
  protected_for( :MEMBER, :member, :show ) {
    @slice_locations = []
    render_mab
  }
end # == get :show

      
put( "/member" )  do
  protected_for( :MEMBER, :member, :update ) {
    current_member.changes_from_editor( clean_room, current_member )
    begin
        current_member.save
        render_success_msg( "Your account has been updated." )
    rescue Sequel::ValidationFailed
        render_error_msg( current_member.error_msg )
    end
  }
end # === put :update


put( "/trash" )  do
  protected_for( :MEMBER, :member, :trash ) {
    current_member.trash_it!
    flash( :success_msg,  "Your account has been trashed." )
  }
end # === put :trash





